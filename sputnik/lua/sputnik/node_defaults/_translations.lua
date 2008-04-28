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

-- A phrase introducing a list of actions that are supported
THIS_PAGE_DEFINED_THE_FOLLOWING_ACTIONS = {
   en_US = [[ In addition to the standard actions, this page defines the following:]],
   ru    = [[ В добавок к стандартным коммандам, эта страница поддерживает следующие:]],
   pt_BR = [[ Além das ações padrão, esta página define também as seguintes: ]],
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
   en_US = "by <a $author_link>$author</a>",
   ru    = "<a $author_link>$author</a>",
   pt_BR = "por <a $author_link>$author</a>",
}

-- Diff link in history
DIFF = {
   en_US = "Diff",
}

-- A button to diff two versions selected by the user
DIFF_SELECTED_VERSIONS = {
   en_US = "Diff selected versions",
}

-----------------------------------------------------------------------------
-----  EDITING  -------------------------------------------------------------
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
   pt_BR = "Tirar Opções Avançadas",
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
   pt_BR = "Traduçõesy",
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

-- A label for the section of the form where the user will edit the page content
EDIT_FORM_CONTENT_HDR = {
   en_US = "Page Content",
   ru    = "Содержание страницы",
   pt_BR = "Conteúdo da página",
}

-- A lable for the section of the form that deals with user id, minor parameter and edit summary
EDIT_FORM_EDIT_INFO_HDR = {
   en_US = "About this Edit",
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

EDIT_FORM_PLEASE_LOGIN = {
   en_US = "Login or create a new user",
   ru    = "Влогнитесь или зарегистрируйтесь",
   pt_BR = "Entre com seus dados ou crie um novo usuário",
}


-- A note to the user that they must be logged in to edit
YOU_MUST_BE_LOGGED_IN = {
   en_US = "You must be logged in to edit a page!  Try again!",
   ru    = "Нужно влогнуться.  Попробуйте снова!",
   pt_BR = "Você precisa estar logado para editar uma página. Por favor tente novamente",
}

MISSING_POST_TOKEN = {
   en_US = "Post token is missing." 
}

MISSING_POST_TIME_STAMP = {
   en_US = "Missing post time stamp."
}

YOUR_POST_TOKEN_HAS_EXPIRED = {
   en_US = "Your edit form has expired."
}

YOUR_POST_TOKEN_IS_INVALID = {
   en_US = "Your post token is invalid."
}

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
   pt_BR = "Salvar",
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
   en_US = "by $author1",
   ru    = "(автор: $author1)", 
   pt_BR = "por $author1",
}

-- In diff mode, this is the phrase introducing the user name of the second author
BY_AUTHOR2 = { "by $author2",
   en_US = "by $author2",
   ru    = "(автор: $author2)", 
   pt_BR = "por $author2",
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
-----  MISCELLANEOUS  -------------------------------------------------------
-----------------------------------------------------------------------------

RECENT_EDITS_TO_SITE = {
   en_US = "Recent edits to $site_title"
}

RECENT_EDITS_TO_PAGE = {
   en_US = "Recent edits to $site_title: $title"
}

INCORRECT_PASSWORD = {
   en_US = "Logging incorrect"
}

RSS_FOR_EDITS_TO_THIS_WIKI = {
   en_US = "RSS for edits to this wiki",
   ru    = "RSS-лента изменение этой вики",
}

RSS_FOR_EDITS_TO_THIS_NODE = {
   en_US = "RSS for edits to this node",
   ru    = "RSS-лента изменение этой станицы",
}

LARGE_RSS_ICON = { 
   en_US = "Large RSS Icon",
   ru    = "Большой значок RSS"
}

SMALL_RSS_ICON = { 
   en_US = "Small RSS Icon",
   ru    = "Maленький значок RSS"
}

]=============]
