<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class UploadCert extends MX_Controller {

    /**
     * Index Page for this controller.
     *
     * Past the login page this loads the page for /ssl/uploadCert.
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
        $i18n = new I18n("base-ssl", $CI->BX_SESSION['loginUser']['localePreference']);
        $system = $CI->getSystem();

        // Initialize Capabilities so that we can poll the access rights as well:
        $Capabilities = new Capabilities($CI->cceClient, $CI->BX_SESSION['loginName'], $CI->BX_SESSION['sessionId']);

        // -- Actual page logic start:

        //
        //--- Get CODB-Object of interest: 
        //

        // We get our $get_form_data early, as this page handles both Vsite and AdmServ SSL certs.
        // Depending on what we modify, we have the "group" information on the URL string - or not.

        $get_form_data = $CI->input->get(NULL, TRUE);
        if (isset($get_form_data['group'])) {

            $group = $get_form_data['group'];

            // Extra check to make sure a siteAdmin isn't messing with the URL param for "group"
            // and then tries to get access to another Vsites certs:
            if (!$Capabilities->getAllowed('manageSite')) {
                if (($Capabilities->getAllowed('siteAdmin')) && ($get_form_data['group'] != $Capabilities->loginUser['site'])) {
                    // Nice people say goodbye, or CCEd waits forever:
                    $CI->cceClient->bye();
                    $CI->serverScriptHelper->destructor();
                    Log403Error("/gui/Forbidden403#seriously");
                }
            }

            $CODBDATA =& $CI->cceClient->getObject('Vsite', array('name' => $get_form_data['group']), 'SSL');
            $CODBDATA['group'] = $get_form_data['group'];
        }
        else {
            $CODBDATA = $CI->cceClient->get($system['OID'], "SSL");            
            $CODBDATA['group'] = "";
        }

        // Only 'serverSSL', 'manageSite' and 'siteAdmin' should be here
        if (!$Capabilities->getAllowed('serverSSL') && !$Capabilities->getAllowed('manageSite') && 
            !($Capabilities->getAllowed('siteAdmin') && $CODBDATA['group'] == $user['site'])) {
            // Nice people say goodbye, or CCEd waits forever:
            $CI->cceClient->bye();
            $CI->serverScriptHelper->destructor();
            Log403Error("/gui/Forbidden403");
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
        $required_keys = array();
        // Set up rules for form validation. These validations happen before we submit to CCE and further checks based on the schemas are done:

        // Empty array for key => values we want to submit to CCE:
        $attributes = array();
        // Items we do NOT want to submit to CCE:
        $ignore_attributes = array("BlueOnyx_Info_Text", "_");
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

            //
            //--- Configure and instantiate the CodeIgniter 'upload' Class:
            //

            $config['upload_path'] = '/tmp/';
            $config['allowed_types'] = 'txt|csr|cert|crt';
            $config['encrypt_name'] = TRUE;
            $config['remove_spaces'] = TRUE;
            $this->load->library('upload', $config);
            $this->upload->do_upload("cert");

            // Get the full path and encrypted/randomized file name:
            $data = $this->upload->data();

            if ($attributes['save']) {

                if (!is_file($data['full_path'])) {
                    //file opening problems
                    $ci_errors[] = new CceError('huh', 0, 'cert', "[[base-ssl.sslImportError4]]");
                    $group = $attributes['group'];
                }
                else {
                    $tmp_cert = $data['full_path'];
                    $group = $attributes['group'];
                    $runas = ($Capabilities->getAllowed('adminUser') ? 'root' : $CI->BX_SESSION['loginName']);
                    $ret = $CI->serverScriptHelper->shell("/usr/sausalito/sbin/ssl_import.pl $tmp_cert --group=$group --type=serverCert", $output, $runas, $CI->BX_SESSION['sessionId']);
                    if ($ret != 0) {
                        // deal with error
                        $ci_errors[] = new CceError('huh', 0, 'cert', "[[base-ssl.sslImportError$ret]]");
                        if (is_file($tmp_cert)) {
                            unlink($tmp_cert);
                        }
                    }
                    else {
                        if (is_file($tmp_cert)) {
                            unlink($tmp_cert);
                        }
                        $CI->cceClient->bye();
                        $CI->serverScriptHelper->destructor();
                        if ($attributes['group'] == '') {
                            header("Location: /ssl/siteSSL");
                        }
                        else {
                            header("Location: /ssl/siteSSL?group=$group");
                        }
                        exit;
                    }
                }
            }
        }

        //
        //--- At this point all checks are done. If we have no errors, we can submit the data to CODB:
        //

        // Join the various error messages:
        $errors = array_merge($ci_errors, $my_errors);

        // If we have no errors and have POST data, we submit to CODB:
        if ((count($errors) == "0") && ($CI->input->post(NULL, TRUE))) {

            // We have no errors. We submit to CODB.
            if ($attributes['save']) {
                // actually save the information

                // use the same ui for admin server and vhosts, so assume System
                // if $attributes['group'] is empty
                if ($attributes['group'] != '') {
                    list($vsite) = $CI->cceClient->find('Vsite', array('name' => $attributes['group']));
                }
                else {
                    $vsite = $system['OID'];
                }
            }

            // CCE errors that might have happened during submit to CODB:
            $CCEerrors = $CI->cceClient->errors();
            foreach ($CCEerrors as $object => $objData) {
                // When we fetch the CCE errors it tells us which field it bitched on. And gives us an error message, which we can return:
                $errors[] = ErrorMessage($i18n->get($objData->message, true, array('key' => $objData->key)) . '<br>&nbsp;');
            }

            // No errors. Reload the entire page to load it with the updated values:
            if ((count($errors) == "0")) {
                if ($attributes['group'] != '') {
                    header("Location: /ssl/siteSSL?group=" . $attributes['group']);
                }
                else {
                    header("Location: /ssl/siteSSL");
                }
                exit;
            }
            else {
                $CODBDATA = $attributes;
            }
        }

        //
        //-- Own page logic:
        //

        //
        //-- Generate page:
        //

        // Pass group along in URL's:
        $urlAppendix = "";
        if (isset($group)) {
            $urlAppendix = "?group=" . $group;
        }

        // Prepare Page:
        $factory = $CI->serverScriptHelper->getHtmlComponentFactory("base-ssl", "/ssl/uploadCert$urlAppendix");
        $BxPage = $factory->getPage();
        $BxPage->setErrors($errors);
        $i18n = $factory->getI18n();

        $product = new Product($CI->cceClient);

        // Set Menu items:
        if ($CODBDATA['group'] != "") {
            // We are in "Site Management" / "SSL":
            $BxPage->setVerticalMenu('base_sitemanage');
            $BxPage->setVerticalMenuChild('base_ssl');
            $page_module = 'base_sitemanage';
        }
        else {
            // We are in "Security" / "SSL"
            $BxPage->setVerticalMenu('base_security');
            $BxPage->setVerticalMenuChild('base_admin_ssl');
            $page_module = 'base_sysmanage';
        }

        //
        // -- Add PagedBlock with Cert Info:
        //

        $header = 'importCert';
        if ($CODBDATA['group']) {
            list($vsite) = $CI->cceClient->find("Vsite", array("name" => $CODBDATA['group']));
            $vsiteObj = $CI->cceClient->get($vsite);
            $fqdn = $vsiteObj['fqdn'];
        }
        else {
            $fqdn = '[[base-ssl.serverDesktop]]';
        }

        $defaultPage = "basic";
        $block =& $factory->getPagedBlock("importCert", array($defaultPage));
        $block->setCurrentLabel($factory->getLabel($header, false, array('fqdn' => $fqdn)));

        $block->setToggle("#");
        $block->setSideTabs(FALSE);
        $block->setShowAllTabs("#");
        $block->setDefaultPage($defaultPage);

        //
        //--- Tab: basic
        //

        $block->addFormField(
            $factory->getFileUpload('cert', ""),
            $factory->getLabel('certUpload'),
            $defaultPage
            );

        // Add some hidden fields that we need later:
        $block->addFormField(
            $factory->getTextField('save', '1', ''),
            $factory->getLabel('save'),
            $defaultPage
            );
        $block->addFormField(
            $factory->getTextField('group', $CODBDATA['group'], ''),
            $factory->getLabel('group'),
            $defaultPage
            );

        //
        //--- Add the Save/Cancel buttons (not for AdmServ-Cert, though)
        //
        $block->addButton($factory->getSaveButton($BxPage->getSubmitAction()));
        $block->addButton($factory->getCancelButton("/ssl/siteSSL$urlAppendix"));

        $page_body[] = $block->toHtml();

        // Out with the page:
        $BxPage->render($page_module, $page_body);

    }       
}
/*
Copyright (c) 2017 Michael Stauber, SOLARSPEED.NET
Copyright (c) 2017 Team BlueOnyx, BLUEONYX.IT
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