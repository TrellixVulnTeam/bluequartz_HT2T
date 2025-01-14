<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');


class Console extends MX_Controller {

    /**
     * Index Page for this controller.
     *
     * Past the login page this loads the page for the console access.
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

        $cookie = array('name' => 'remote', 'path' => '/', 'value' => $CI->BX_SESSION['sessionId'], 'expire' => '0');
        $this->input->set_cookie($cookie);

        // Line up the ducks for CCE-Connection:
        include_once('ServerScriptHelper.php');
        $CI->serverScriptHelper = new ServerScriptHelper($CI->BX_SESSION['sessionId'], $CI->BX_SESSION['loginName']);
        $CI->cceClient = $CI->serverScriptHelper->getCceClient();
        $user = $CI->BX_SESSION['loginUser'];
        $userShell = $CI->cceClient->getObject("User", array("name" => $CI->BX_SESSION['loginName']), "Shell");
        $i18n = new I18n("base-disk", $CI->BX_SESSION['loginUser']['localePreference']);
        $system = $CI->getSystem();
        $systemRemote = $CI->cceClient->get($system['OID'], "Remote");

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

        // -- Actual page logic start:

        //-- Generate page:

        // Prepare Page:
        $factory = $CI->serverScriptHelper->getHtmlComponentFactory("base-remote", "/remote/console/");
        $BxPage = $factory->getPage();
        $BxPage->setErrors($errors);
        $i18n = $factory->getI18n();

        // Set Menu items:
        if (!isset($group)) {
            $BxPage->setVerticalMenu('base_programsPersonal');
            $BxPage->setVerticalMenuChild('console_personal');
            $page_module = 'base_personalProfile';
            $url_suffix = '';
        }
        else {
            if ($group == "server") {
                $BxPage->setVerticalMenu('base_programs');
                $BxPage->setVerticalMenuChild('console_server');
                $page_module = 'base_sysmanage';
            }
            else {
                
                $BxPage->setVerticalMenu('base_programsSite');
                $BxPage->setVerticalMenuChild('console_vsite');
                $page_module = 'base_sitemanage';
            }
            $url_suffix = '?group=' . $group;
        }

        $defaultPage = "basicSettingsTab";

        $block =& $factory->getPagedBlock("header", array($defaultPage));

        $block->setToggle("#");
        $block->setSideTabs(FALSE);
        $block->setDefaultPage($defaultPage);

        $uri_full = 'https://' . $_SERVER['SERVER_NAME'] . ':81/bxshell/?' . $CI->BX_SESSION['loginName'] . '=' . time();
        $uri_short = '/bxshell/?' . $CI->BX_SESSION['loginName'] . '=' . time();

        if (!isset($userShell['enabled'])) {
            $uri_full = 'https://' . $_SERVER['SERVER_NAME'] . ':81/remote/noaccess/?' . $CI->BX_SESSION['loginName'] . '=' . time();
            $uri_short = '/remote/noaccess/?' . $CI->BX_SESSION['loginName'] . '=' . time();
        }

        if (uri_string() != "remote/console/full") {

            if ($systemRemote['enabled'] == "0") {
                    $disabled_TEXT = "<div class='flat_area grid_16'><br>" . $i18n->getClean("[[base-remote.service_disabled]]") . "</div>";
                    $disabledtext = $factory->getHtmlField("admin_text", $disabled_TEXT, 'r');
                    $disabledtext->setLabelType("nolabel");
                    $block->addFormField(
                      $disabledtext,
                      $factory->getLabel(" ", false),
                      $defaultPage
                    );
            }
            else {

                $my_TEXT = "<div class='flat_area grid_16'><br>" . $i18n->getClean("[[base-remote.info_text]]") . "</div>";
                $infotext = $factory->getHtmlField("info_text", $my_TEXT, 'r');
                $infotext->setLabelType("nolabel");
                $block->addFormField(
                  $infotext,
                  $factory->getLabel(" ", false),
                  $defaultPage
                );

                if ($CI->BX_SESSION['loginName'] == 'admin') {

                    $admin_TEXT = "<div class='flat_area grid_16'><br>" . $i18n->getClean("[[base-remote.admin_text]]") . "</div>";
                    $admintext = $factory->getHtmlField("admin_text", $admin_TEXT, 'r');
                    $admintext->setLabelType("nolabel");
                    $block->addFormField(
                      $admintext,
                      $factory->getLabel(" ", false),
                      $defaultPage
                    );
                }

                $block->setSelf("/remote/console/full$url_suffix");
                $applet = '<iframe height=600 width=720 src="' . $uri_short . '" scrolling="no"></iframe>';

                $block->addFormField(
                    $factory->getRawHTML("applet", $applet),
                    $factory->getLabel("AllowOverride_OptionsField"),
                    $defaultPage
                );
            }

            $page_body[] = $block->toHtml();
        }
        else {

            if ($systemRemote['enabled'] == "0") {
                    $disabled_TEXT = "<div class='flat_area grid_16'><br>" . $i18n->getClean("[[base-remote.service_disabled]]") . "</div>";
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

                $my_TEXT = "<div class='flat_area grid_16'><br>" . $i18n->getClean("[[base-remote.info_text]]") . "</div>";
                $infotext = $factory->getHtmlField("info_text", $my_TEXT, 'r');
                $infotext->setLabelType("nolabel");
                $block->addFormField(
                  $infotext,
                  $factory->getLabel(" ", false),
                  $defaultPage
                );

                if ($CI->BX_SESSION['loginName'] == 'admin') {

                    $admin_TEXT = "<div class='flat_area grid_16'><br>" . $i18n->getClean("[[base-remote.admin_text]]") . "</div>";
                    $admintext = $factory->getHtmlField("admin_text", $admin_TEXT, 'r');
                    $admintext->setLabelType("nolabel");
                    $block->addFormField(
                      $admintext,
                      $factory->getLabel(" ", false),
                      $defaultPage
                    );
                }
            }

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