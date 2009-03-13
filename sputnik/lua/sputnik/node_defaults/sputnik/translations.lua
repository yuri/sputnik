module(..., package.seeall)

NODE = {
   title="Translations",
   prototype="@Lua_Config",
}
NODE.content = [=============[

-- If you edit this page outside Sputnik, please use an editor 
-- that handles unicode properly, e.g. "gedit".

FALLBACKS = {
  en = "en_US",
  pt = "pt_BR",
  _all = "en_US",
}

-----------------------------------------------------------------------------
-----  NORMAL VIEW  ---------------------------------------------------------
-----------------------------------------------------------------------------

-- The login link
LOGIN = {
   en_US = "Login",
   ru    = "Представиться",     
   pt_BR = "Login",
}

OR = {
   en_US = "or",
   ru    = "или",     
   pt_BR = "ou",
}

REGISTER = {
   en_US = "register",
   ru    = "зарегистрироваться",     
   pt_BR = "Criar conta",
}

-- The login button

LOGIN = {
   en_US = "Login",
   ru    = "Войти",     
   pt_BR = "Entrar",
}

-- User greeting
HI_USER = {
   en_US = "Hi, $user!",
   ru    = "Салют, $user!",
   pt_BR = "Olá, $user!", 
}

-- The logout link
LOGOUT = {
   en_US = "Logout",
   ru    = "Выйти",     
   pt_BR = "Sair",
}

-- The link to edit the content of the page
EDIT = {
   en_US = "Edit",
   ru    = "Редактировать",     
   pt_BR = "Editar",
}

-- The link to the history of changes for the page
HISTORY = {
   en_US = "History",
   ru    = "История",     
   pt_BR = "Histórico",
}

-- The link to the node configurations
CONFIGURE = {
   en_US = "Configure",
   ru    = "Настройки",     
   pt_BR = "Configuração",
}

-- The "powered by sputnik" label in the footer.
POWERED_BY_SPUTNIK = {
   en_US = "Powered by <a $sputnik_link>Sputnik</a>",
   ru    = "Движим «<a $sputnik_link>Спутником</a>»", 
}

-- ALT text for the logo.
LOGO = {
   en_US = "Logo (links to home page)",
   ru    = "Логотип (ссылка на первую страницу)",
}


-- A label for the search button.
SEARCH = {
   en_US = "Search",
   ru    = "Поиск",
   pt_BR = "Busca",	
}

-- A tooltip for the search button.
TOOLTIP_FOR_SEARCH = {
   en_US = "Search this wiki",
   ru    = "Поиск по этому вики",
   pt_BR = "Busca nessa wiki",
}

TOOLTIP_FOR_SEARCH_BOX = {
   en_US = "Search query",
   ru    = "Термины поиска",
}

CURRENT_SECTION = {
   en_US = "Current section"
}

CURRENT_SUBSECTION = {
   en_US = "Current subsection"
}

CURRENT_PAGE = {
   en_US = "Current page"
}


-----------------------------------------------------------------------------
-----  MISC ACTIONS  --------------------------------------------------------
-----------------------------------------------------------------------------

-- A note to the user that they are not allowed to perform the action
ACTION_NOT_ALLOWED = {
   en_US = "Sorry, you do not have permissions to perform this action",
}

-- A message to tell the user they are not allowed to edit the node
NOT_ALLOWED_TO_EDIT = {
   en_US = "Sorry, you are not allowed to edit this node.",
   ru = "К сожалению Вы не имеете разрешение на редактирование этой страницы"
}

-- A messaging saying that this action doesn't work for this page
PAGE_DOES_NOT_SUPPORT_ACTION = {
   en_US = [[ Whoops, page <a $link>$title</a> does not support action <code>.$action</code>.]],
   ru    = [[ Ой. Страница <a $link>$title</a> не знает как реагировать на комманду <code>.$action</code>.]], 
   pt_BR = [[ A página <a $link>$title</a> não suporta a ação <code>.$action</code>. ]],
}

-----------------------------------------------------------------------------
-----  HISTORY VIEW  --------------------------------------------------------
-----------------------------------------------------------------------------

-- A phrase introducing a list of dates for browsing edits by day
CHANGES_BY_DATE = {
   en_US = "Changes by date",
   ru    = "Изменения по дням",
   pt_BR = "Modificações ordenadas por data",
}

-- A phrase introducing a list of months for browsing edits
CHOOSE_ANOTHER_MONTH = {
   en_US = "Choose another month",
   ru    = "Смотреть другой месяц",
   pt_BR = "Selecione outro mês",
}

-- A phrase introducing the author of the edit
BY_AUTHOR = {
   en_US = "by <a $author_link>$author</a> on $date at $time",
   ru    = "<a $author_link>$author</a> ($date, $time)",
   pt_BR = "por <a $author_link>$author</a> ($date, $time)",
}

-- A phrase introducing the author of the edit in global history
AUTHOR_SAVED_VERSION = {
   en_US = "<img alt='author' src='$author_icon'/> <a $author_link>$author</a> at $time: <a $version_link>$version</a>",
   ru    = "<img alt='author' src='$author_icon'/> <a $author_link>$author</a> сохранил <a $version_link>$version</a> в $time",
   pt_BR = "<img alt='author' src='$author_icon'/> <a $author_link>$author</a> guardou <a $version_link>$version</a> ás $time",
}

-- Diff link in history
DIFF = {
   en_US = "Diff",
}

-- A button to diff two versions selected by the user
DIFF_SELECTED_VERSIONS = {
   en_US = "Diff selected versions",
}

SHOW_CHANGES_SINCE_PREVIOUS = {
   en_US = "Show changes since previous version",
}

-----------------------------------------------------------------------------
-----  EDITING: BASIC -------------------------------------------------------
-----------------------------------------------------------------------------

-- A label for the section of the Edit form that sets page parameters
EDIT_FORM_PAGE_PARAMS_HDR = { 
   en_US = "Page Parameters",
   ru    = "Параметры страницы",
   pt_BR = "Parâmetros da página",
}

-- A label for the "name" parameter
EDIT_FORM_PAGE_NAME = { 
   en_US = "Page Name (for URL)",
   ru    = "Имя страницы (URL)",
   pt_BR = "Nome da página (p/ URL)",
}

-- A lable for the "title" parameter
EDIT_FORM_TITLE = {
   en_US = "Page Title",
   ru    = "Заголовок",
   pt_BR = "Título da Página",
}

-- A label for the section of the form with advanced parameters
EDIT_FORM_ADVANCED_SECTION = {
   en_US = "Advanced Fields",
   ru    = "Дополнительные поля",
   pt_BR = "Campos avançados",
}

-- A label for the section of the form with even more advanced parameters
EDIT_FORM_GURU_SECTION = {
   en_US = "Guru Fields",
   ru    = "Поля для гуру",
   pt_BR = "Campos ainda mais avançados",
}

-- A label for the section of the form with html templates
EDIT_FORM_HTML_SECTION = {
   en_US = "HTML Fields",
   ru    = "Поля HTML",
   pt_BR = "Campos HTML",
}

EDIT_FORM_HTML_MAIN = {
   en_US = "Main",
}
EDIT_FORM_HTML_HEAD = {
   en_US = "Head",
}
EDIT_FORM_HTML_BODY = {
   en_US = "Body",
}
EDIT_FORM_HTML_HEADER = {
   en_US = "Header",
}
EDIT_FORM_HTML_MENU = {
   en_US = "Menu",
}
EDIT_FORM_HTML_LOGO = {
   en_US = "Logo",
}
EDIT_FORM_HTML_SEARCH = {
   en_US = "Search",
}
EDIT_FORM_HTML_PAGE = {
   en_US = "Page",
}
EDIT_FORM_HTML_SIDEBAR = {
   en_US = "Sidebar",
}
EDIT_FORM_HTML_FOOTER = {
   en_US = "Footer",
}

-- A label for the section of the form where the user will edit the page content
EDIT_FORM_CONTENT_SECTION = {
   en_US = "Page Content",
   ru    = "Содержание страницы",
   pt_BR = "Conteúdo da página",
}

EDIT_FORM_CONTENT = EDIT_FORM_CONTENT_SECTION

-- A label for the section of the form where the user can edit the breadcrumb text
EDIT_FORM_BREADCRUMB = {
	en_US = "Breadcrumb Text",
}

-- A lable for the section of the form that deals with user id, minor parameter and edit summary
EDIT_FORM_EDIT_INFO_SECTION = {
   en_US = "About This Edit",
   ru    = "О ваших изменениях",
   pt_BR = "Sobre esta edição",
}

-- A label for the "minor" parameter
EDIT_FORM_MINOR = {
   en_US = "Minor Edit",
   ru    = "Ничего серьезного",
   pt_BR = "Pequena Edição",
}

-- A label for the "summary" parameter
EDIT_FORM_SUMMARY = {
   en_US = "Edit Summary",
   ru    = "Резюме",
   pt_BR = "Sumário da Edição",
}

--- A label for the honeypot field - the user shouldn't type anything in it
EDIT_FORM_HONEY = {
   en_US = "Don't put anything here",
}


-----------------------------------------------------------------------------
-----  EDITING: FILE UPLOAD  ------------------------------------------------
-----------------------------------------------------------------------------

-- A label for the "file" parameter for file uploads
EDIT_FORM_FILE_UPLOAD = {
   en_US = "File to upload",
}

EDIT_FORM_FILE_TYPE = {
	en_US = "File 'Content-type'",
}

EDIT_FORM_FILE_NAME = {
	en_US = "Filename",
}

EDIT_FORM_FILE_SIZE = {
	en_US = "File size",
}

EDIT_FORM_FILE_DESCRIPTION = {
	en_US = "Description",
}

EDIT_FORM_FILE_COPYRIGHT = {
	en_US = "Copyright",
}

EDIT_FORM_SUBJECT = {
   en_US = "Subject",
}
-----------------------------------------------------------------------------
-----  EDITING: ADMIN -------------------------------------------------------
-----------------------------------------------------------------------------

-- The link to show fields for "advanced" page parameteters       
SHOW_ADVANCED_OPTIONS = {
   en_US = "Show Advanced Options",
   ru    = "показать дополнительный опции",
   pt_BR = "Exibir Opções Avançadas",
}

-- The link to hide fields for "advanced" page parameteters       
HIDE_ADVANCED_OPTIONS = {
   en_US = "Hide Advanced Options",
   ru    = "спрятать дополнительный опции",
   pt_BR = "Ocultar Opções Avançadas",
}

-- A label for the "category" parameter
EDIT_FORM_CATEGORY = {
   en_US = "Category", 
   ru    = "Раздел",
   pt_BR = "Categoria",
}

-- A label for the "prototype" parameter
EDIT_FORM_PROTOTYPE = {
   en_US = "Prototype",
   ru    = "Прототип",
   pt_BR = "Prototipo",
}

-- A label for the "save_hook" parameter
EDIT_FORM_SAVE_HOOK = {
   en_US = "Save Hook"
}

-- A label for the "templates" parameter
EDIT_FORM_TEMPLATES = {
   en_US = "Templates",
   ru    = "Шаблоны",
   pt_BR = "Templates",
}

-- A label for the "translations" parameter
EDIT_FORM_TRANSLATIONS = {
   en_US = "Translations",
   ru    = "Переводы",
   pt_BR = "Traduções",
}

-- A label for the "permissions" parameter
EDIT_FORM_PERMISSIONS = {
   en_US = "Permissions",
   ru    = "Права доступа",
   pt_BR = "Permissões",
}

-- A label for the "actions" parameter
EDIT_FORM_ACTIONS = {
   en_US = "Actions",
   ru    = "Комманды",
   pt_BR = "Ações",
}

-- A label for the "config" field in the edit form
EDIT_FORM_CONFIG = {
   en_US = "Config",
   ru    = "Прочие настройки",
}

EDIT_FORM_MARKUP_MODULE = {
   en_US = "Markup Module",
   ru    = "Модуль разметки",
}


EDIT_FORM_FIELDS = {
   en_US = "Fields",
   ru    = "Поля",
   pt_BR = "Campos",
}

EDIT_FORM_EDIT_UI = {
   en_US = "Edit UI",
   ru    = "Редактирование",
}

EDIT_FORM_ADMIN_EDIT_UI = {
   en_US = "Admin Edit UI",
   ru    = "Редактирование для админа",
}

EDIT_FORM_CHILD_PROTO = {
   en_US = "Child Prototype"
}

EDIT_FORM_COLLECTION_SECTION = {
   en_US = "Collection Fields"
}

EDIT_FORM_CHILD_UID_FORMAT = {
    en_US = "Child UID Format"
}

EDIT_FORM_DISC_SECTION = {
   en_US = "Discussion Fields"
}

EDIT_FORM_AUTHOR = {
   en_US = "Author"
}

EDIT_FORM_CREATION_TIME = {
   en_US = "Creation Time",
}

EDIT_FORM_ACTIVITY_TIME = {
   en_US = "Activity Time",
}

EDIT_FORM_ACTIVITY_NODE = {
   en_US = "Activity Node",
}

EDIT_FORM_COMMENT_AUTHOR = {
   en_US = "Comment Author",
}

EDIT_FORM_COMMENT_PARENT = {
    en_US = "Comment Parent",
}

EDIT_FORM_COMMENT_SECTION = {
    en_US = "Comment Fields"
}

EDIT_FORM_CONTENT_TEMPLATE = {
   en_US = "Content Template"
}

EDIT_FORM_HTML_CONTENT = {
   en_US = "Content Template"
}

EDIT_FORM_XML_TEMPLATE = {
   en_US = "XML Template"
}

EDIT_FORM_HTTP_SECTION = {
   en_US = "HTTP Fields"
}

EDIT_FORM_HTTP_CACHE_CONTROL = {
   en_US = "Cache-Control"
}

EDIT_FORM_HTTP_EXPIRES = {
   en_US = "Expires"
}

EDIT_FORM_XSSFILTER_ALLOWED_TAGS = {
   en_US = "Tags Allowed for XSSFilter"
}

-----------------------------------------------------------------------------
-----  LOGIN  ---------------------------------------------------------------
-----------------------------------------------------------------------------

EDIT_FORM_PLEASE_LOGIN = {
   en_US = "Enter Your Login",
   ru    = "Влогнитесь",
   pt_BR = "Entre com seus dados",
}

-- A label for the "user" field
EDIT_FORM_USER = {
   en_US = "User",
   ru    = "Имя",
   pt_BR = "Usuário",
}

-- A label for the "password" field
EDIT_FORM_PASSWORD = {
   en_US = "Password",
   ru    = "Пароль",
   pt_BR = "Senha",
}


-- A note to the user that they must be logged in to edit
YOU_MUST_BE_LOGGED_IN = {
   en_US = "You must be logged in to edit a page!  Try again!",
   ru    = "Нужно влогнуться.  Попробуйте снова!",
   pt_BR = "Você precisa estar logado para editar uma página. Por favor tente novamente",
}

-- Wrong password entered
INCORRECT_PASSWORD = {
   en_US = "The user name and password didn't match (or no such user)"
}

-----------------------------------------------------------------------------
-----  POST TOKEN ISSUES ----------------------------------------------------
-----------------------------------------------------------------------------

-- The post token expired.  This may mean that the user had the edit form
-- for too long, so it may make more sense to say that the edit form expired
-- rather than the token.
YOUR_POST_TOKEN_HAS_EXPIRED = {
   en_US = "Your edit form has expired."
}

-- The following messages shouldn't be shown to a normal user.
-- It's ok not to translate them, probably.

MISSING_POST_TOKEN = {
   en_US = "Post token is missing." 
}
MISSING_POST_TIME_STAMP = {
   en_US = "Missing post time stamp."
}
YOUR_POST_TOKEN_IS_INVALID = {
   en_US = "Your post token is invalid."
}

-----------------------------------------------------------------------------
-----  PREVIEW --------------------------------------------------------------
-----------------------------------------------------------------------------

-- A phrase saying that the user is previewing unsaved changes, used in the Preview mode.
PREVIEWING_UNSAVED_CHANGES = {
   en_US = "Previewing your <b>unsaved</b> changes",
   ru    = "Проверка ваших <b>несохраненных</b> изменений",
   pt_BR = "Visualizando altrações ainda <b>não</b> salvas",
}

-- A link to the part of the form where the user can change the content (used in the Preview mode).
CHANGE = {
   en_US = "change",
   ru    = "изменить",
   pt_BR = "Modificar",
}

-- The label for the "preview" button in the edit forms. 
PREVIEW = {
   en_US = "preview",
   ru    = "посмотреть",
   pt_BR = "Visualizar",
}

-- The label for the "save" button in the edit forms. 
SAVE = {
   en_US = "save",
   ru    = "сохранить",
   pt_BR = "Guardar",
}

-- The label for the "cancel" button in the edit forms. 
CANCEL = {
   en_US = "cancel",
   ru    = "отменить",
   pt_BR = "Cancelar",
}


-----------------------------------------------------------------------------
-----  DIFFING  -------------------------------------------------------------
-----------------------------------------------------------------------------

-- In diff mode, this is the phrase introducing the user name of the first author
BY_AUTHOR1 = {
   en_US = "by $author1 on $date1 at $time1",
   ru    = "(автор: $author1, время: $date1, $time1)", 
   pt_BR = "por $author1 ($date1, $time1)",
}

-- In diff mode, this is the phrase introducing the user name of the second author
BY_AUTHOR2 = { "by $author2",
   en_US = "by $author2 on $date2 at $time2",
   ru    = "(автор: $author2, время: $date2, $time2)", 
   pt_BR = "por $author2 ($date2, $time2)",
}


-----------------------------------------------------------------------------
-----  CHECKING LUA CODE  ---------------------------------------------------
-----------------------------------------------------------------------------

-- A message saying that a chunk of Lua code parses correctly.
THIS_LUA_CODE_PARSES_CORRECTLY = {
   en_US = "This Lua code parses correctly.",
}

-- A message saying that a chunk of Lua fails to parse.
THIS_LUA_CODE_HAS_PROBLEMS = {
   en_US = "This Lua code has some problems:",
}

-----------------------------------------------------------------------------
-----  RECENT EDITS  --------------------------------------------------------
-----------------------------------------------------------------------------

RECENT_EDITS_TO_SITE = {
   en_US = "Recent edits to $site_title"
}

RECENT_EDITS_TO_NODE = {
   en_US = "Recent edits to $site_title: $title"
}

RSS_FOR_EDITS_TO_THIS_WIKI = {
   en_US = "RSS for edits to this wiki",
   ru    = "RSS-лента изменение этой вики",
}

RSS_FOR_EDITS_TO_THIS_NODE = {
   en_US = "RSS for edits to this node",
   ru    = "RSS-лента изменение этой станицы",
}

RSS = RSS_FOR_EDITS_TO_THIS_NODE

BUTTON = {
   en_US = "Button",
   ru    = "Кнопка",
}

EDIT_FORM_HTML_META_KEYWORDS = {
   en_US = "HTML/Meta/Keywords",
}

EDIT_FORM_HTML_META_DESCRIPTION = {
   en_US = "HTML/Meta/Description",
}

EDIT_FORM_REDIRECT_DESTINATION = {
	en_US = "Redirect",
}

-----------------------------------------------------------------------------
-----  REGISTRATION  --------------------------------------------------------
-----------------------------------------------------------------------------

-- User agrees to terms of service.
I_AGREE_TO_TERMS_OF_SERVICE = {
   en_US = "I have read to and agree to the <a href='$url'>Terms of Service</a><br />"
}

-- Subject for the account activation email
ACCOUNT_ACTIVATION = {
   en_US = "Account activation"
}

-- The body of the account activation email
ACTIVATION_MESSAGE_BODY = {
   en_US = [[
In order to activate your account at $site_name, please click the following link.
If the link isn't click-able, please copy and paste the URL into your web browser.
You will be asked to confirm the registered information.

$activation_link

Thank you!
]]
}

ERROR_SENDING_ACTIVATION_EMAIL = {
   en_US = "Sorry, there was a problem sending your activation email."
}

ACTIVATION_MESSAGE_SENT = {
   en_US = [[ An activation message was sent to your email address.  
              Please check your email use the link in the message to activate your account.]]
}


-- Form label for new user name
EDIT_FORM_NEW_USERNAME = {
   en_US = "User name"
}

-- Form label for new password
EDIT_FORM_NEW_PASSWORD = {
   en_US = "Password"
}

EDIT_FORM_NEW_EMAIL = {
   en_US = "Email"
}

-- Form label for terms of service
EDIT_FORM_AGREE_TOS = {
   en_US = "Terms of Service"
}

-- Form label for confirming new password
EDIT_FORM_NEW_PASSWORD_CONFIRM = {
   en_US = "Confirm Password"
}

TWO_VERSIONS_OF_NEW_PASSWORD_DO_NOT_MATCH = {
   en_US = "Two version of the new password do not match."
}

NEW_EMAIL_NOT_VALID = {
   en_US = "The email you entered is not valid."
}

MUST_CONFIRM_TOS = {
   en_US = "You must agree to the terms of service in order to create a new account.",
}

USERNAME_TAKEN = {
   en_US = "This user name is already taken."
}

SUCCESSFULLY_CREATED_ACCOUNT = {
   en_US = "Successfully created your new account."
}


PLEASE_CONFIRM_PASSWORD = {
   en_US = "Please confirm new password"
}

COULD_NOT_CONFIRM_NEW_PASSWORD = {
   en_US = "The password you entered is different from the one given originally."
}



-----------------------------------------------------------------------------
-----  CAPTCHA  --------------------------------------------------------
-----------------------------------------------------------------------------

COULD_NOT_VERIFY_CAPTCHA = {
   en_US = "Could not verify captcha: "
}

-- A note telling the user that they need to enter captcha because they are not logged in.
ANONYMOUS_USERS_MUST_ENTER_CAPTCHA = {
   en_US = "Anonymous users must enter <a href='http://en.wikipedia.org/wiki/Captcha'>captcha</a> below."
}

NO_SUCH_NODE = {
   en_US = "This node by this name does not exist."
}

PLEASE_PICK_A_TYPE_TO_CREATE_A_NEW_NODE = {
   en_US = [[The node by this name does not exist, but you can create it.
             Please pick one of the node types below.]]
}

THIS_PAGE_DEFINED_THE_FOLLOWING_ACTIONS = {
   en_US = "This node supports the following commands:"
}

-----------------------------------------------------------------------------
-----  RSS OUTPUT  --------------------------------------------------------
-----------------------------------------------------------------------------

NO_EDIT_SUMMARY = {
   en_US = "No edit summary provided",
}

ANONYMOUS_USER = {
   en_US = "Anonymous user",
}

-----------------------------------------------------------------------------
-----  COMMENTS AND FORUMS  -------------------------------------------------
-----------------------------------------------------------------------------

REPLY = {
   en_US = "Reply",
   pt_BR = "Responder",
   ru = "Ответить"
}

QUOTE = {
   en_US = "Quote",
   ru = "Цитировать"
}

]=============]
