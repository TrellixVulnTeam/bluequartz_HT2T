<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class Ablsettings extends MX_Controller {

	/**
	 * Index Page for this controller.
	 *
	 * Past the login page this loads the page for /console/ablsettings.
	 *
	 */

	public function index() {

		$CI =& get_instance();

	    // We load the BlueOnyx helper library first of all, as we heavily depend on it:
	    $this->load->helper('blueonyx');
	    init_libraries();

  		// Need to load 'BxPage' for page rendering:
  		$this->load->library('BxPage');
		$MX =& get_instance();

	    // Get $sessionId and $loginName from Cookie (if they are set):
	    $sessionId = $CI->input->cookie('sessionId');
	    $loginName = $CI->input->cookie('loginName');
	    $locale = $CI->input->cookie('locale');

	    // Line up the ducks for CCE-Connection:
	    include_once('ServerScriptHelper.php');
		$serverScriptHelper = new ServerScriptHelper($sessionId, $loginName);
		$cceClient = $serverScriptHelper->getCceClient();
		$user = $cceClient->getObject("User", array("name" => $loginName));
		$i18n = new I18n("base-console", $user['localePreference']);
		$system = $cceClient->getObject("System");

		// Initialize Capabilities so that we can poll the access rights as well:
		$Capabilities = new Capabilities($cceClient, $loginName, $sessionId);

		// -- Actual page logic start:

		// Not serverConfig? Bye, bye!
		if (!$Capabilities->getAllowed('serverConfig')) {
			// Nice people say goodbye, or CCEd waits forever:
			$cceClient->bye();
			$serverScriptHelper->destructor();
			Log403Error("/gui/Forbidden403");
		}

		//
		//--- Get CODB-Object of interest updated: 
		//

		$ourOID = $cceClient->find("pam_abl_settings");
		$cceClient->set($ourOID[0], "", array('reload_config' => time()));
		$errors = $cceClient->errors();

		//
		//--- Get CODB-Object of interest loaded: 
		//

		$CODBDATA = $cceClient->getObject("pam_abl_settings");

		//
		//--- Handle form validation:
		//

	    // We start without any active errors:
	    $errors = array();
	    $extra_headers =array();
	    $ci_errors = array();
	    $my_errors = array();

		// Shove submitted input into $form_data after passing it through the XSS filter:
		$form_data = $CI->input->post(NULL, TRUE);

		// Form fields that are required to have input:
		$required_keys = array("");

    	// Set up rules for form validation. These validations happen before we submit to CCE and further checks based on the schemas are done:

		// Empty array for key => values we want to submit to CCE:
    	$attributes = array();
    	// Items we do NOT want to submit to CCE:
    	$ignore_attributes = array("pam_abl_location");
		if (is_array($form_data)) {
			// Function GetFormAttributes() walks through the $form_data and returns us the $parameters we want to
			// submit to CCE. It intelligently handles checkboxes, which only have "on" set when they are ticked.
			// In that case it pulls the unticked status from the hidden checkboxes and addes them to $parameters.
			// It also transformes the value of the ticked checkboxes from "on" to "1". 
			//
			// Additionally it generates the form_validation rules for CodeIgniter.
			//
			// params: $i18n				i18n Object of the error messages
			// params: $form_data			array with form_data array from CI
			// params: $required_keys		array with keys that must have data in it. Needed for CodeIgniter's error checks
			// params: $ignore_attributes	array with items we want to ignore. Such as Labels.
			// return: 						array with keys and values ready to submit to CCE.
			$attributes = GetFormAttributes($i18n, $form_data, $required_keys, $ignore_attributes, $i18n);
		}
		//Setting up error messages:
		$CI->form_validation->set_message('required', $i18n->get("[[palette.val_is_required]]", false, array("field" => "\"%s\"")));		

	    // Do we have validation related errors?
	    if ($CI->form_validation->run() == FALSE) {

			if (validation_errors()) {
				// Set CI related errors:
				$ci_errors = array(validation_errors('<div class="alert dismissible alert_red"><img width="40" height="36" src="/.adm/images/icons/small/white/alarm_bell.png"><strong>', '</strong></div>'));
			}		    
			else {
				// No errors. Pass empty array along:
				$ci_errors = array();
			}
		}

		//
		//--- Own error checks:
		//

		if ($CI->input->post(NULL, TRUE)) {
			// Not needed. Thank you, jQuery!
		}

		//
		//--- At this point all checks are done. If we have no errors, we can submit the data to CODB:
		//

		// Join the various error messages:
		$errors = array_merge($ci_errors, $my_errors);

		// If we have no errors and have POST data, we submit to CODB:
		if ((count($errors) == "0") && ($CI->input->post(NULL, TRUE))) {

			// We have no errors. We submit to CODB.

			// Any additional parameters that we need to pass on?
			$attributes['update_config'] = time();
			$attributes['force_update'] = time();

			// Convert "disabled" back to the right format:
			if ($attributes['user_rule'] == "disabled") {
			    $attributes['user_rule'] = "50000/1m";
			}
			$attributes['user_rule'] = "!admin/cced=10000/1h," . $attributes['user_rule'];

			if ($attributes['host_rule'] == "disabled") {
			    $attributes['host_rule'] = "50000/1m";
			}
			$attributes['host_rule'] = "*=" . $attributes['host_rule'];

	  		// Actual submit to CODB:
			$cceClient->setObject("pam_abl_settings", $attributes);

			// CCE errors that might have happened during submit to CODB:
			$CCEerrors = $cceClient->errors();
			foreach ($CCEerrors as $object => $objData) {
				// When we fetch the CCE errors it tells us which field it bitched on. And gives us an error message, which we can return:
				$errors[] = ErrorMessage($i18n->get($objData->message, true, array('key' => $objData->key)) . '<br>&nbsp;');
			}

			// No errors. Reload the entire page to load it with the updated values:
			if ((count($errors) == "0")) {
				header("Location: /console/ablsettings");
				exit;
			}
			else {
				$CODBDATA = $cceClient->getObject("pam_abl_settings");
			}

		}

		//
	    //-- Generate page:
	    //

		// Prepare Page:
		$factory = $serverScriptHelper->getHtmlComponentFactory("base-console", "/console/ablsettings");
		$BxPage = $factory->getPage();
		$BxPage->setErrors($errors);
		$i18n = $factory->getI18n();

		// Set Menu items:
		$BxPage->setVerticalMenu('base_security');
		$BxPage->setVerticalMenuChild('pam_abl');		
		$page_module = 'base_sysmanage';

		$defaultPage = "pam_abl_config_location";

		$block =& $factory->getPagedBlock("pam_abl_head", array($defaultPage));

		$block->setToggle("#");
		$block->setSideTabs(FALSE);
		$block->setDefaultPage($defaultPage);

		// pam_abl.conf location:
		$pam_abl_location_Field = $factory->getTextField("pam_abl_location", "/etc/security/pam_abl.conf", "r");
		$pam_abl_location_Field->setOptional ('silent');
		$block->addFormField(
		    $pam_abl_location_Field,
		    $factory->getLabel("pam_abl_location"),
		    "pam_abl_config_location"
		);

		// host_purge:
		$host_purge_choices=array(
		    "1h" => "1h", 
		    "2h" => "2h", 
		    "3h" => "3h", 
		    "4h" => "4h", 
		    "6h" => "6h", 
		    "8h" => "8h", 
		    "10h" => "10h", 
		    "12h" => "12h", 
		    "18h" => "18h", 
		    "1d" => "1d", 
		    "2d" => "2d", 
		    "3d" => "3d", 
		    "4d" => "4d", 
		    "8d" => "8d" 
		    );

		// user_purge:
		$user_purge_choices=array(
		    "1h" => "1h", 
		    "2h" => "2h", 
		    "3h" => "3h", 
		    "4h" => "4h", 
		    "6h" => "6h", 
		    "8h" => "8h", 
		    "10h" => "10h", 
		    "12h" => "12h", 
		    "18h" => "18h", 
		    "1d" => "1d", 
		    "2d" => "2d", 
		    "3d" => "3d", 
		    "4d" => "4d", 
		    "8d" => "8d" 
		    );

		$host_purge = $CODBDATA['host_purge'];
		$user_purge = $CODBDATA['user_purge'];

		// user_purge Input:
		$user_purge_select = $factory->getMultiChoice("user_purge",array_values($user_purge_choices));
		$user_purge_select->setSelected($user_purge_choices[$user_purge], true);
		$block->addFormField($user_purge_select,$factory->getLabel("user_purge"), "pam_abl_config_location");

		// user_purge Input:
		$host_purge_select = $factory->getMultiChoice("host_purge",array_values($host_purge_choices));
		$host_purge_select->setSelected($host_purge_choices[$host_purge], true);
		$block->addFormField($host_purge_select,$factory->getLabel("host_purge"), "pam_abl_config_location");

		// user_rule:
		$user_rule_raw = $CODBDATA['user_rule'];
		if (preg_match('/!admin\/cced/', $user_rule_raw)) {
		    $ur_diss = explode(',', $user_rule_raw);
		    $user_rule = $ur_diss[1];
		}
		else {
		    // assume default because someone manually messed with the rules and removed the safeguard for admin access to the GUI:
		    $user_rule = "30/1h";
		}

		// build array:
		$user_rule_choices=array(
		    "1/1h" => "1/1h", 
		    "3/1h" => "3/1h", 
		    "5/1h" => "5/1h", 
		    "10/1h" => "10/1h", 
		    "20/1h" => "20/1h", 
		    "30/1h" => "30/1h", 
		    "40/1h" => "40/1h", 
		    "50/1h" => "50/1h", 
		    "60/1h" => "60/1h", 
		    "100/1h" => "100/1h",
		    "50000/1m" => "disabled"
		    );

		// user_rule Input:
		$user_rule_select = $factory->getMultiChoice("user_rule",array_values($user_rule_choices));
		$user_rule_select->setSelected($user_rule_choices[$user_rule], true);
		$block->addFormField($user_rule_select,$factory->getLabel("user_rule"), "pam_abl_config_location");

		// host_rule:
		$host_rule_raw = $CODBDATA['host_rule'];
		$hr_diss = explode('=', $host_rule_raw);
		$host_rule = $hr_diss[1];

		// build array:
		$host_rule_choices=array(
		    "1/1h" => "1/1h", 
		    "3/1h" => "3/1h", 
		    "5/1h" => "5/1h", 
		    "10/1h" => "10/1h", 
		    "20/1h" => "20/1h", 
		    "30/1h" => "30/1h", 
		    "40/1h" => "40/1h", 
		    "50/1h" => "50/1h", 
		    "60/1h" => "60/1h", 
		    "100/1h" => "100/1h",
		    "50000/1m"=> "disabled"
		    );

		// host_rule Input:
		$host_rule_select = $factory->getMultiChoice("host_rule",array_values($host_rule_choices));
		$host_rule_select->setSelected($host_rule_choices[$host_rule], true);
		$block->addFormField($host_rule_select,$factory->getLabel("host_rule"), "pam_abl_config_location");

		// Add the buttons
		$block->addButton($factory->getSaveButton($BxPage->getSubmitAction()));
		$block->addButton($factory->getCancelButton("/console/ablsettings"));

		// Nice people say goodbye, or CCEd waits forever:
		$cceClient->bye();
		$serverScriptHelper->destructor();

		$page_body[] = $block->toHtml();

		// Out with the page:
	    $BxPage->render($page_module, $page_body);

	}		
}

/*
Copyright (c) 2014 Michael Stauber, SOLARSPEED.NET
Copyright (c) 2014 Team BlueOnyx, BLUEONYX.IT
All Rights Reserved.

1. Redistributions of source code must retain the above copyright 
   notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright 
   notice, this list of conditions and the following disclaimer in 
   the documentation and/or other materials provided with the 
   distribution.

3. Neither the name of the copyright holder nor the names of its 
   contributors may be used to endorse or promote products derived 
   from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS 
FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE 
COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT 
LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN 
ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
POSSIBILITY OF SUCH DAMAGE.

You acknowledge that this software is not designed or intended for 
use in the design, construction, operation or maintenance of any 
nuclear facility.

*/
?>