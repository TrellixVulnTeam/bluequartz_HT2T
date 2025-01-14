<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');


class Netdata extends MX_Controller {

    /**
     * Index Page for this controller.
     *
     * Past the login page this loads the page for the netdata access.
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

        $cookie = array('name' => 'netdata', 'path' => '/', 'value' => $CI->BX_SESSION['sessionId'], 'expire' => '0');
        $this->input->set_cookie($cookie);

        // Line up the ducks for CCE-Connection:
        include_once('ServerScriptHelper.php');
        $CI->serverScriptHelper = new ServerScriptHelper($CI->BX_SESSION['sessionId'], $CI->BX_SESSION['loginName']);
        $CI->cceClient = $CI->serverScriptHelper->getCceClient();
        $user = $CI->BX_SESSION['loginUser'];
        $i18n = new I18n("base-netdata", $CI->BX_SESSION['loginUser']['localePreference']);
        $system = $CI->getSystem();
        $systemNetdata = $CI->cceClient->get($system['OID'], "Netdata");

        // Initialize Capabilities so that we can poll the access rights as well:
        $Capabilities = new Capabilities($CI->cceClient, $CI->BX_SESSION['loginName'], $CI->BX_SESSION['sessionId']);

        // No Shell access? Bye, bye!
        if ((!$Capabilities->getAllowed('serverShell')) || (!$Capabilities->getAllowed('siteShell')) || (!$Capabilities->getAllowed('resellerShell'))) {
            // Nice people say goodbye, or CCEd waits forever:
            $CI->cceClient->bye();
            $CI->serverScriptHelper->destructor();
            Log403Error("/gui/Forbidden403");
        }

        // Get URL strings:
        $get_form_data = $CI->input->get(NULL, TRUE);
        if (isset($get_form_data['group'])) {
            // We have a group:
            $group = $get_form_data['group'];
        }

        // Required array setup:
        $errors = array();
        $extra_headers = array();

        //
        //--- Handle form validation:
        //

        // We start without any active errors:
        $ci_errors = array();
        $my_errors = array();

        // Shove submitted input into $form_data after passing it through the XSS filter:
        $form_data = $CI->input->post(NULL, TRUE);

        // Form fields that are required to have input:
        $required_keys = array();

        // Set up rules for form validation. These validations happen before we submit to CCE and further checks based on the schemas are done:

        // Empty array for key => values we want to submit to CCE:
        $attributes = array();
        // Items we do NOT want to submit to CCE:
        $ignore_attributes = array("BlueOnyx_Info_Text");
        if (is_array($form_data)) {
            // Function GetFormAttributes() walks through the $form_data and returns us the $parameters we want to
            // submit to CCE. It intelligently handles checkboxes, which only have "on" set when they are ticked.
            // In that case it pulls the unticked status from the hidden checkboxes and addes them to $parameters.
            // It also transformes the value of the ticked checkboxes from "on" to "1". 
            //
            // Additionally it generates the form_validation rules for CodeIgniter.
            //
            // params: $i18n                i18n Object of the error messages
            // params: $form_data           array with form_data array from CI
            // params: $required_keys       array with keys that must have data in it. Needed for CodeIgniter's error checks
            // params: $ignore_attributes   array with items we want to ignore. Such as Labels.
            // return:                      array with keys and values ready to submit to CCE.
            $attributes = GetFormAttributes($i18n, $form_data, $required_keys, $ignore_attributes);
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
            $attributes['force_update'] = time();

            // Actual submit to CODB:
            $CI->cceClient->set($system['OID'], "Netdata",  $attributes);

            // CCE errors that might have happened during submit to CODB:
            $CCEerrors = $CI->cceClient->errors();
            foreach ($CCEerrors as $object => $objData) {
                // When we fetch the CCE errors it tells us which field it bitched on. And gives us an error message, which we can return:
                $errors[] = ErrorMessage($i18n->get($objData->message, true, array('key' => $objData->key)) . '<br>&nbsp;');
            }
            $systemNetdata = $CI->cceClient->get($system['OID'], "Netdata");
        }

        //
        //-- Generate page:
        //

        // Prepare Page:
        $factory = $CI->serverScriptHelper->getHtmlComponentFactory("base-netdata", "/netdata/netdata/");
        $BxPage = $factory->getPage();
        $BxPage->setErrors($errors);
        $i18n = $factory->getI18n();

        // Determine if we're using the dark or the light skin:
        if (preg_match('/skin_light/', $user['ChorizoStyle'])) {
            $theme = 'white';
        }
        else {
            $theme = 'slate';
        }

        // Set Menu items:
        if (!isset($group)) {
            $BxPage->setVerticalMenu('base_programsPersonal');
            $BxPage->setVerticalMenuChild('netdata_personal');
            $page_module = 'base_personalProfile';
            $url_suffix = '';
        }
        else {
            if ($group == "server") {
                $BxPage->setVerticalMenu('base_programs');
                $BxPage->setVerticalMenuChild('netdata_server');
                $page_module = 'base_sysmanage';
            }
            else {
                $BxPage->setVerticalMenu('base_programsSite');
                $BxPage->setVerticalMenuChild('netdata_vsite');
                $page_module = 'base_sitemanage';
            }
            $url_suffix = '?group=' . $group . '#menu_system_submenu_cpu;theme=' . $theme . ';help=true';
        }

        $defaultPage = "basicSettingsTab";

        $block =& $factory->getPagedBlock("header", array($defaultPage));

        $block->setToggle("#");
        $block->setSideTabs(FALSE);
        $block->setDefaultPage($defaultPage);

        $uri_full = 'https://' . $_SERVER['SERVER_NAME'] . ':81/bxnetdata/?' . $CI->BX_SESSION['loginName'] . '=' . time() . '#menu_system_submenu_cpu;theme=' . $theme . ';help=true';
        $uri_short = '/bxnetdata/?' . $CI->BX_SESSION['loginName'] . '=' . time() . '#menu_system_submenu_cpu;theme=' . $theme . ';help=true';

        if (!isset($systemNetdata['enabled'])) {
            $uri_full = 'https://' . $_SERVER['SERVER_NAME'] . ':81/bxshell/noaccess/?' . $CI->BX_SESSION['loginName'] . '=' . time();
            $uri_short = '/bxshell/noaccess/?' . $CI->BX_SESSION['loginName'] . '=' . time();
        }

        if (uri_string() != "netdata/netdata/full") {

            $block->addFormField(
                $factory->getBoolean("enabled", $systemNetdata["enabled"]),
                $factory->getLabel("enabledField"),
                $defaultPage
            );

            if ($systemNetdata['enabled'] == "0") {
                    $disabled_TEXT = "<div class='flat_area grid_16'><br>" . $i18n->getClean("[[base-netdata.service_disabled]]") . "</div>";
                    $disabledtext = $factory->getHtmlField("admin_text", $disabled_TEXT, 'r');
                    $disabledtext->setLabelType("nolabel");
                    $block->addFormField(
                      $disabledtext,
                      $factory->getLabel(" ", false),
                      $defaultPage
                    );
            }
            else {

                $block->setSelf("/netdata/netdata/full$url_suffix");
                $applet = '<iframe height=600 width=720 src="' . $uri_short . '" scrolling="yes"></iframe>';

                $block->addFormField(
                    $factory->getRawHTML("applet", $applet),
                    $factory->getLabel("AllowOverride_OptionsField"),
                    $defaultPage
                );
            }

            // Add the buttons
            $block->addButton($factory->getSaveButton($BxPage->getSubmitAction()));
            $block->addButton($factory->getCancelButton("/apache/apache"));

            $page_body[] = $block->toHtml();
        }
        else {

            $block->addFormField(
                $factory->getBoolean("enabled", $systemNetdata["enabled"]),
                $factory->getLabel("enabledField"),
                $defaultPage
            );

            if ($systemNetdata['enabled'] == "0") {
                    $disabled_TEXT = "<div class='flat_area grid_16'><br>" . $i18n->getClean("[[base-netdata.service_disabled]]") . "</div>";
                    $disabledtext = $factory->getHtmlField("admin_text", $disabled_TEXT, 'r');
                    $disabledtext->setLabelType("nolabel");
                    $block->addFormField(
                      $disabledtext,
                      $factory->getLabel(" ", false),
                      $defaultPage
                    );
            }
            else {

                $BxPage->setExtraBodyTag('<body onload="javascript: poponload()">');

                $BxPage->setExtraHeaders('<script type="text/javascript">');
                $BxPage->setExtraHeaders('function poponload() {');
                $BxPage->setExtraHeaders("  window.open('$uri_full','_blank','toolbar=no, location=no, directories=no, status=no, menubar=no, scrollbars=yes, resizable=yes, copyhistory=yes, width=1024, height=800');");
                $BxPage->setExtraHeaders('}');
                $BxPage->setExtraHeaders('</script>');
            }

            // Add the buttons
            $block->addButton($factory->getSaveButton($BxPage->getSubmitAction()));
            $block->addButton($factory->getCancelButton("/apache/apache"));

            $page_body[] = $block->toHtml();

        }
        // Out with the page:
        $BxPage->render($page_module, $page_body);

    }       
}
/*
Copyright (c) 2016 Michael Stauber, SOLARSPEED.NET
Copyright (c) 2016 Team BlueOnyx, BLUEONYX.IT
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