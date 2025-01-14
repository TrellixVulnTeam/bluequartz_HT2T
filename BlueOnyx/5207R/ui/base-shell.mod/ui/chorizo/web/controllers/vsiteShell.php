<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class VsiteShell extends MX_Controller {

	/**
	 * Index Page for this controller.
	 *
	 * Past the login page this loads the page for /shell/vsiteShell.
	 *
	 */

	public function index() {

		$CI =& get_instance();

	    // We load the BlueOnyx helper library first of all, as we heavily depend on it:
	    $this->load->helper('blueonyx');
	    init_libraries();

  		// Need to load 'BxPage' for page rendering:
  		$this->load->library('BxPage');

	    // Get $CI->BX_SESSION['sessionId'] and $CI->BX_SESSION['loginName'] from Cookie (if they are set):
	    $CI->BX_SESSION['sessionId'] = $CI->input->cookie('sessionId');
	    $CI->BX_SESSION['loginName'] = $CI->input->cookie('loginName');

	    // Line up the ducks for CCE-Connection:
	    include_once('ServerScriptHelper.php');
		$CI->serverScriptHelper = new ServerScriptHelper($CI->BX_SESSION['sessionId'], $CI->BX_SESSION['loginName']);
		$CI->cceClient = $CI->serverScriptHelper->getCceClient();
		$user = $CI->BX_SESSION['loginUser'];
		$i18n = new I18n("base-shell", $CI->BX_SESSION['loginUser']['localePreference']);
		$system = $CI->getSystem();

		// Initialize Capabilities so that we can poll the access rights as well:
		$Capabilities = new Capabilities($CI->cceClient, $CI->BX_SESSION['loginName'], $CI->BX_SESSION['sessionId']);

		// -- Actual page logic start:

		// Get URL strings:
		$get_form_data = $CI->input->get(NULL, TRUE);

		//
		//-- Validate GET data:
		//

		if (isset($get_form_data['group'])) {
			// We have a group set:
			$group = $get_form_data['group'];
		}
		else {
			// Don't play games with us!
			// Nice people say goodbye, or CCEd waits forever:
			$CI->cceClient->bye();
			$CI->serverScriptHelper->destructor();
			Log403Error("/gui/Forbidden403#1");
		}

		//
		//-- Access Rights Check for Vsite level pages:
		// 
		// 1.) Checks if the Group/Vsite exists.
		// 2.) Checks if the user is systemAdministrator
		// 3.) Checks if the user is Reseller of the given Group/Vsite
		// 4.) Checks if the iser is siteAdmin of the given Group/Vsite
		// Returns Forbidden403 if *none* of that is the case.
		if (!$Capabilities->getGroupAdmin($group)) {
			// Nice people say goodbye, or CCEd waits forever:
			$CI->cceClient->bye();
			$CI->serverScriptHelper->destructor();
			Log403Error("/gui/Forbidden403#2");
		}

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
		$required_keys = array("connectRate");

    	// Set up rules for form validation. These validations happen before we submit to CCE and further checks based on the schemas are done:

		// Empty array for key => values we want to submit to CCE:
    	$attributes = array();
    	// Items we do NOT want to submit to CCE:
    	$ignore_attributes = array();
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

	  		// Actual submit to CODB:
			if ($attributes['save'] == "1") {
				$CI->cceClient->setObject('Vsite', array('enabled' => $attributes['Shell_enabled']), 'Shell', array('name' => $group));
			}

			// CCE errors that might have happened during submit to CODB:
			$CCEerrors = $CI->cceClient->errors();
			foreach ($CCEerrors as $object => $objData) {
				// When we fetch the CCE errors it tells us which field it bitched on. And gives us an error message, which we can return:
				$errors[] = ErrorMessage($i18n->get($objData->message, true, array('key' => $objData->key)) . '<br>&nbsp;');
			}
		}

		//
	    //-- Generate page:
	    //

		if (($Capabilities->getAllowed('adminUser')) || ($Capabilities->getAllowed('manageSite'))) {   
		    $access = 'rw';
		    $is_site_admin = false;
		}
		elseif ($Capabilities->getAllowed('serverShell') && $group == $Capabilities->loginUser['site']) {
		    $access = 'r';
		    $is_site_admin = true;
		}
		else {
		    $access = 'r';
		    $is_site_admin = true;
		}

		// Prepare Page:
		$factory = $CI->serverScriptHelper->getHtmlComponentFactory("base-shell", "/shell/vsiteShell?group=$group");
		$BxPage = $factory->getPage();
		$BxPage->setErrors($errors);
		$i18n = $factory->getI18n();

		// Set Menu items:
		$BxPage->setVerticalMenu('base_siteadmin');
		$BxPage->setVerticalMenuChild('base_siteshell');
		$page_module = 'base_sitemanage';

		// Get Objects of interest:
		$site = $CI->cceClient->getObject('Vsite', array('name' => $group));
		$siteShell = $CI->cceClient->getObject('Vsite', array('name' => $group), 'Shell');

        //
        //-- Reseller: Can the reseller that owns this Vsite modify this?
        //
        $VsiteOwnerObj = $CI->cceClient->getObject("User", array("name" => $site['createdUser']));
        if ($VsiteOwnerObj['name'] != "admin") {
            $resellerCaps = $CI->cceClient->scalar_to_array($VsiteOwnerObj['capabilities']);
            if (!in_array('resellerShell', $resellerCaps)) {
                $siteShell['enabled'] = '0';
                $access = 'r';
            }
        }

		$defaultPage = "basicSettingsTab";

		$block =& $factory->getPagedBlock("siteShellSettings", array($defaultPage));
		$block->setLabel($factory->getLabel('siteShellSettings', false, array('fqdn' => $site['fqdn'])));

		$block->setToggle("#");
		$block->setSideTabs(FALSE);
		$block->setDefaultPage($defaultPage);

		$block->addFormField($factory->getTextField('group', $group, ''), $factory->getLabel('group'), $defaultPage);
		$block->addFormField($factory->getTextField('save', '1', ''), $factory->getLabel('save'), $defaultPage);

		$shellEnable = $factory->getBoolean('Shell_enabled', $siteShell['enabled'], $access);
		$block->addFormField($shellEnable, $factory->getLabel('enableShell'), $defaultPage);

		// Add the buttons
		if (!$is_site_admin) {
			$block->addButton($factory->getSaveButton($BxPage->getSubmitAction()));
			$block->addButton($factory->getCancelButton("/shell/vsiteShell?group=$group"));
		}

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