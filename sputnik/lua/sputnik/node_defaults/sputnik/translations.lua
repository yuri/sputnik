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
  es = "es_VE"
}

-----------------------------------------------------------------------------
-----  NORMAL VIEW  ---------------------------------------------------------
-----------------------------------------------------------------------------

-- The login link
LOGIN = {
   en_US = "Sign in",
   ru    = "Представиться",     
   pt_BR = "Faça login",
   es_VE = "Iniciar sesión",
}

OR = {
   en_US = "or",
   ru    = "или",     
   pt_BR = "ou",
   es_VE = "o",
}

REGISTER = {
   en_US = "register",
   ru    = "зарегистрироваться",     
   pt_BR = "crie uma conta",
   es_VE = "crear cuenta",
}

SUBMIT = {
   en_US = "submit",
}

-- The login button

LOGIN = {
   en_US = "Login",
   ru    = "Войти",     
   pt_BR = "Entrar",
   es_VE = "Iniciar sesión",
}

-- The logout link
LOGOUT = {
   en_US = "Logout",
   ru    = "Выйти",     
   pt_BR = "Sair",
   es_VE = "Salir",
}

-- The link to edit the content of the page
EDIT = {
   en_US = "Edit",
   ru    = "Редактировать",     
   pt_BR = "Editar",
   es_VE = "Editar",
}

-- The link to the history of changes for the page
HISTORY = {
   en_US = "History",
   ru    = "История",     
   pt_BR = "Histórico",
   es_VE = "Historia de cambios",
}

-- The link to the node configurations
CONFIGURE = {
   en_US = "Configure",
   ru    = "Настройки",     
   pt_BR = "Configuração",
   es_VE = "Configuración",
}

-- The "powered by sputnik" label in the footer.
POWERED_BY_SPUTNIK = {
   en_US = "Powered by <a $sputnik_link>Sputnik</a>",
   ru    = "Движим «<a $sputnik_link>Спутником</a>»", 
   es_VE = "Potenciado por <a $sputnik_link>Sputnik</a>",
}

-- ALT text for the logo.
LOGO = {
   en_US = "Logo (links to home page)",
   ru    = "Логотип (ссылка на первую страницу)",
   es_VE = "Logo (lleva a la página principal)",
}


-- A label for the search button.
SEARCH = {
   en_US = "Search",
   ru    = "Поиск",
   pt_BR = "Busca",
   es_VE = "Buscar",
}

-- A tooltip for the search button.
TOOLTIP_FOR_SEARCH = {
   en_US = "Search this wiki",
   ru    = "Поиск по этому вики",
   pt_BR = "Busca nessa wiki",
   es_VE = "Buscar en esta wiki",
}

TOOLTIP_FOR_SEARCH_BOX = {
   en_US = "Search query",
   ru    = "Термины поиска",
   es_VE = "Buscar",
}

CURRENT_SECTION = {
   en_US = "Current section",
   es_VE = "Sección actual",
}

CURRENT_SUBSECTION = {
   en_US = "Current subsection",
   es_VE = "Subsección actual",
}

CURRENT_PAGE = {
   en_US = "Current page",
   es_VE = "Página actual",
}


-----------------------------------------------------------------------------
-----  MISC ACTIONS  --------------------------------------------------------
-----------------------------------------------------------------------------

-- A note to the user that they are not allowed to perform the action
ACTION_NOT_ALLOWED = {
   en_US = "Sorry, you do not have permissions to perform this action",
   es_VE = "Lo sentimos, no tiene los permisos necesarios para realizar esta acción",
}

-- A message to tell the user they are not allowed to edit the node
NOT_ALLOWED_TO_EDIT = {
   en_US = "Sorry, you are not allowed to edit this node.",
   ru = "К сожалению Вы не имеете разрешение на редактирование этой страницы",
   es_VE = "Lo sentimos, no tiene permitido editar este nodo",
}

-- A messaging saying that this action doesn't work for this page
PAGE_DOES_NOT_SUPPORT_ACTION = {
   en_US = [[ Whoops, page <a $link>$title</a> does not support action <code>.$action</code>.]],
   ru    = [[ Ой. Страница <a $link>$title</a> не знает как реагировать на комманду <code>.$action</code>.]], 
   pt_BR = [[ A página <a $link>$title</a> não suporta a ação <code>.$action</code>. ]],
   es_VE = [[ Ups, la página <a $link>$title</a> no soporta la acción <code>.$action</code>.]],
}

-----------------------------------------------------------------------------
-----  HISTORY VIEW  --------------------------------------------------------
-----------------------------------------------------------------------------

-- A phrase introducing a list of dates for browsing edits by day
CHANGES_BY_DATE = {
   en_US = "Changes by date",
   ru    = "Изменения по дням",
   pt_BR = "Modificações ordenadas por data",
   es_VE = "Modifiaciones en orden cronológico",
}

-- A phrase introducing a list of months for browsing edits
CHOOSE_ANOTHER_MONTH = {
   en_US = "Choose another month",
   ru    = "Смотреть другой месяц",
   pt_BR = "Selecione outro mês",
   es_VE = "Seleccione otro mes",
}

-- A phrase introducing the author of the edit
BY_AUTHOR = {
   en_US = "by <a $author_link>$author</a> on $date at $time",
   ru    = "<a $author_link>$author</a> ($date, $time)",
   pt_BR = "por <a $author_link>$author</a> ($date, $time)",
   es_VE = "por <a $author_link>$author</a> el ($date, a las $time)",
}

-- A phrase introducing the author of the edit in global history
AUTHOR_SAVED_VERSION = {
   en_US = "<img alt='author' src='$author_icon'/> $if_author_link[[<a $author_link>]]$author$if_author_link[[</a>]] at $time: <a $version_link>$version</a>",
   ru    = "<img alt='author' src='$author_icon'/> $if_author_link[[<a $author_link>]]$author$if_author_link[[</a>]] сохранил <a $version_link>$version</a> в $time",
   pt_BR = "<img alt='author' src='$author_icon'/> $if_author_link[[<a $author_link>]]$author$if_author_link[[</a>]] guardou <a $version_link>$version</a> ás $time",
   es_VE = "<img alt='author' src='$author_icon'/> $if_author_link[[<a $author_link>]]$author$if_author_link[[</a>]] at $time: <a $version_link>$version</a>",
}

-- Diff link in history
DIFF = {
   en_US = "Diff",
   es_VE = "Mostrar diferencias",
}

-- A button to diff two versions selected by the user
DIFF_SELECTED_VERSIONS = {
   en_US = "Diff selected versions",
   es_VE = "Mostrar diferencias entre versiones seleccionadas",
}

SHOW_CHANGES_SINCE_PREVIOUS = {
   en_US = "Show changes since previous version",
   es_VE = "Mostrar cambios desde la versión anterior",
}

-----------------------------------------------------------------------------
-----  EDITING: BASIC -------------------------------------------------------
-----------------------------------------------------------------------------

-- A label for the section of the Edit form that sets page parameters
EDIT_FORM_PAGE_PARAMS_HDR = { 
   en_US = "Page Parameters",
   ru    = "Параметры страницы",
   pt_BR = "Parâmetros da página",
   es_VE = "Parámetros de página",
}

-- A label for the "name" parameter
EDIT_FORM_PAGE_NAME = { 
   en_US = "Page Name (for URL)",
   ru    = "Имя страницы (URL)",
   pt_BR = "Nome da página (p/ URL)",
   es_VE = "Nombre de página (para URL)",
}

-- A label for the "is_deleted" parameter

EDIT_FORM_IS_DELETED = {
   en_US = "Mark this node as deleted",
}

-- A lable for the "title" parameter
EDIT_FORM_TITLE = {
   en_US = "Page Title",
   ru    = "Заголовок",
   pt_BR = "Título da Página",
   es_VE = "Título de página",
}

-- A lable for the "owners" parameter
EDIT_FORM_OWNERS = {
   en_US = "Owners",
   ru    = "Хозяева",
   pt_BR = "Donos",
}

-- A label for the section of the form with advanced parameters
EDIT_FORM_ADVANCED_SECTION = {
   en_US = "Advanced Fields",
   ru    = "Дополнительные поля",
   pt_BR = "Campos avançados",
   es_VE = "Campos avanzados",
}

-- A label for the section of the form with even more advanced parameters
EDIT_FORM_GURU_SECTION = {
   en_US = "Guru Fields",
   ru    = "Поля для гуру",
   pt_BR = "Campos ainda mais avançados",
   es_VE = "Campos más avanzados (Guru)",
}

-- A label for the section of the form with html templates
EDIT_FORM_HTML_SECTION = {
   en_US = "HTML Fields",
   ru    = "Поля HTML",
   pt_BR = "Campos HTML",
   es_VE = "Campos HTML",
}

EDIT_FORM_HTML_MAIN = {
   en_US = "Main",
   es_VE = "Principal",
}
EDIT_FORM_HTML_HEAD = {
   en_US = "Head",
   es_VE = "Cabeza (HTML)",
}
EDIT_FORM_HTML_BODY = {
   en_US = "Body",
   es_VE = "Cuerpo (HTML)",
}
EDIT_FORM_HTML_HEADER = {
   en_US = "Header",
   es_VE = "Cabecera",
}
EDIT_FORM_HTML_MENU = {
   en_US = "Menu",
   es_VE = "Menu",
}
EDIT_FORM_HTML_LOGO = {
   en_US = "Logo",
   es_VE = "Logo",
}
EDIT_FORM_HTML_SEARCH = {
   en_US = "Search",
   es_VE = "Búsqueda",
}
EDIT_FORM_HTML_PAGE = {
   en_US = "Page",
   es_VE = "Página",
}
EDIT_FORM_HTML_SIDEBAR = {
   en_US = "Sidebar",
   es_VE = "Barra lateral",
}
EDIT_FORM_HTML_FOOTER = {
   en_US = "Footer",
   es_VE = "Pie de página",
}

-- A label for the section of the form where the user will edit the page content
EDIT_FORM_CONTENT_SECTION = {
   en_US = "Page Content",
   ru    = "Содержание страницы",
   pt_BR = "Conteúdo da página",
   es_VE = "Contenido de página",
}

EDIT_FORM_CONTENT = EDIT_FORM_CONTENT_SECTION

-- A label for the section of the form where the user can edit the breadcrumb text
EDIT_FORM_BREADCRUMB = {
   en_US = "Breadcrumb Text",
   es_VE = "Texto de navegación por migajas (breadcrumb)",
}

-- A lable for the section of the form that deals with user id, minor parameter and edit summary
EDIT_FORM_EDIT_INFO_SECTION = {
   en_US = "A summary of your changes",
   ru    = "О ваших изменениях",
   pt_BR = "Sobre esta edição",
   es_VE = "Sobre esta edición",
}

-- A label for the "minor" parameter
EDIT_FORM_MINOR = {
   en_US = "Minor Edit",
   ru    = "Ничего серьезного",
   pt_BR = "Pequena Edição",
   es_VE = "Edición menor",
}

-- A label for the "summary" parameter
EDIT_FORM_SUMMARY = {
   en_US = "Edit Summary",
   ru    = "Резюме",
   pt_BR = "Sumário da Edição",
   es_VE = "Sumario de edición",
}

--- A label for the honeypot field - the user shouldn't type anything in it
EDIT_FORM_HONEY = {
   en_US = "Don't put anything here",
   es_VE = "No escriba nada aquí",
}


-----------------------------------------------------------------------------
-----  EDITING: FILE UPLOAD  ------------------------------------------------
-----------------------------------------------------------------------------

-- A label for the "file" parameter for file uploads
EDIT_FORM_FILE_UPLOAD = {
   en_US = "File to upload",
   es_VE = "Archivo a cargar",
}

EDIT_FORM_FILE_TYPE = {
   en_US = "File 'Content-type'",
   es_VE = "Archivo 'Content-type'",
}

EDIT_FORM_FILE_NAME = {
   en_US = "Filename",
   es_VE = "Nombre de archivo",
}

EDIT_FORM_FILE_SIZE = {
   en_US = "File size",
   es_VE = "Tamaño de archivo",
}

EDIT_FORM_FILE_DESCRIPTION = {
   en_US = "Description",
   es_VE = "Descripción de archivo",
}

EDIT_FORM_FILE_COPYRIGHT = {
   en_US = "Copyright",
   es_VE = "Derechos de autor",
}

EDIT_FORM_SUBJECT = {
   en_US = "Subject",
   es_VE = "Asunto",
}
-----------------------------------------------------------------------------
-----  EDITING: ADMIN -------------------------------------------------------
-----------------------------------------------------------------------------

-- The link to show fields for "advanced" page parameteters       
SHOW_ADVANCED_OPTIONS = {
   en_US = "Show Advanced Options",
   ru    = "показать дополнительный опции",
   pt_BR = "Exibir Opções Avançadas",
   es_VE = "Mostrar opciones avanzadas",
}

-- The link to hide fields for "advanced" page parameteters       
HIDE_ADVANCED_OPTIONS = {
   en_US = "Hide Advanced Options",
   ru    = "спрятать дополнительный опции",
   pt_BR = "Ocultar Opções Avançadas",
   es_VE = "Ocultar opciones avanazadas",
}

-- A label for the "category" parameter
EDIT_FORM_CATEGORY = {
   en_US = "Category", 
   ru    = "Раздел",
   pt_BR = "Categoria",
   es_VE = "Categoría",
}

-- A label for the "prototype" parameter
EDIT_FORM_PROTOTYPE = {
   en_US = "Prototype",
   ru    = "Прототип",
   pt_BR = "Prototipo",
   es_VE = "Prototipo",
}

-- A label for the "save_hook" parameter
EDIT_FORM_SAVE_HOOK = {
   en_US = "Save Hook",
   es_VE = "Save Hook",
}

-- A label for the "templates" parameter
EDIT_FORM_TEMPLATES = {
   en_US = "Templates",
   ru    = "Шаблоны",
   pt_BR = "Templates",
   es_VE = "Plantillas",
}

-- A label for the "translations" parameter
EDIT_FORM_TRANSLATIONS = {
   en_US = "Translations",
   ru    = "Переводы",
   pt_BR = "Traduções",
   es_VE = "Traducciones",
}

-- A label for the "permissions" parameter
EDIT_FORM_PERMISSIONS = {
   en_US = "Permissions",
   ru    = "Права доступа",
   pt_BR = "Permissões",
   es_VE = "Permisos",
}

-- A label for the "actions" parameter
EDIT_FORM_ACTIONS = {
   en_US = "Actions",
   ru    = "Комманды",
   pt_BR = "Ações",
   es_VE = "Acciones",
}

-- A label for the "config" field in the edit form
EDIT_FORM_CONFIG = {
   en_US = "Config",
   ru    = "Прочие настройки",
   es_VE = "Configuración",
}

EDIT_FORM_MARKUP_MODULE = {
   en_US = "Markup Module",
   ru    = "Модуль разметки",
   es_VE = "Modulo de marcado",
}


EDIT_FORM_FIELDS = {
   en_US = "Fields",
   ru    = "Поля",
   pt_BR = "Campos",
   es_VE = "Campos",
}

EDIT_FORM_EDIT_UI = {
   en_US = "Edit UI",
   ru    = "Редактирование",
   es_VE = "Editar interfaz gráfica",
}

EDIT_FORM_ADMIN_EDIT_UI = {
   en_US = "Admin Edit UI",
   ru    = "Редактирование для админа",
   es_VE = "Editar interfaz gráfica (Administrador)",
}

EDIT_FORM_CHILD_PROTO = {
   en_US = "Child Prototype",
   es_VE = "Prototipo hijo",
}

EDIT_FORM_COLLECTION_SECTION = {
   en_US = "Collection Fields",
   es_VE = "Campos de colección",
}

EDIT_FORM_CHILD_UID_FORMAT = {
    en_US = "Child UID Format",
   es_VE = "Formato de UID hijo",
}

EDIT_FORM_SORT_PARAMS = {
    en_US = "Sort Parameters"
}

EDIT_FORM_DISC_SECTION = {
   en_US = "Discussion Fields",
   es_VE = "Campos de discusión",
}

EDIT_FORM_AUTHOR = {
   en_US = "Author",
   es_VE = "Autor",
}

EDIT_FORM_CREATION_TIME = {
   en_US = "Creation Time",
   es_VE = "Hora de creación",
}

EDIT_FORM_ACTIVITY_TIME = {
   en_US = "Activity Time",
   es_VE = "Hora de actividad",
}

EDIT_FORM_ACTIVITY_NODE = {
   en_US = "Activity Node",
   es_VE = "Nodo de actividad",
}

EDIT_FORM_COMMENT_AUTHOR = {
   en_US = "Comment Author",
   es_VE = "Comentario de autor",
}

EDIT_FORM_COMMENT_PARENT = {
    en_US = "Comment Parent",
    es_VE = "Comentario padre",
}

EDIT_FORM_COMMENT_SECTION = {
    en_US = "Comment Fields",
    es_VE = "Campos de comentarios",
}

EDIT_FORM_CONTENT_TEMPLATE = {
   en_US = "Content Template",
   es_VE = "Plantilla de contenido",
}

EDIT_FORM_HTML_CONTENT = {
   en_US = "Content Template",
   es_VE = "Plantilla de contenido",
}

EDIT_FORM_XML_TEMPLATE = {
   en_US = "XML Template",
   es_VE = "Plantilla XML",
}

EDIT_FORM_HTTP_SECTION = {
   en_US = "HTTP Fields",
   es_VE = "Campos HTTP",
}

EDIT_FORM_HTTP_CACHE_CONTROL = {
   en_US = "Cache-Control",
   es_VE = "Control de cache",
}

EDIT_FORM_HTTP_EXPIRES = {
   en_US = "Expires",
   es_VE = "Expiración",
}

EDIT_FORM_XSSFILTER_ALLOWED_TAGS = {
   en_US = "Tags Allowed for XSSFilter",
   es_VE = "Etiquetas permitidas para filtro XSS",
}

-----------------------------------------------------------------------------
-----  LOGIN  ---------------------------------------------------------------
-----------------------------------------------------------------------------

EDIT_FORM_PLEASE_LOGIN = {
   en_US = "Enter Your Login",
   ru    = "Влогнитесь",
   pt_BR = "Entre com seus dados",
   es_VE = "Por favor inicie sesión",
}

-- A label for the "user" field
EDIT_FORM_USER = {
   en_US = "User",
   ru    = "Имя",
   pt_BR = "Usuário",
   es_VE = "Usuario",
}

-- A label for the "password" field
EDIT_FORM_PASSWORD = {
   en_US = "Password",
   ru    = "Пароль",
   pt_BR = "Senha",
   es_VE = "Contraseña",
}


-- A note to the user that they must be logged in to edit
YOU_MUST_BE_LOGGED_IN = {
   en_US = "You must be logged in to edit a page!  Try again!",
   ru    = "Нужно влогнуться.  Попробуйте снова!",
   pt_BR = "Você precisa estar logado para editar uma página. Por favor tente novamente",
   es_VE = "¡Debe iniciar sesión para editar una página! Intente de nuevo",
}

-- Wrong password entered
INCORRECT_PASSWORD = {
   en_US = "The user name and password didn't match (or no such user)",
   es_VE = "El nombre de usuario y contraseña no concuerdan (o el usuario no existe)"
}

-----------------------------------------------------------------------------
-----  POST TOKEN ISSUES ----------------------------------------------------
-----------------------------------------------------------------------------

-- The post token expired.  This may mean that the user had the edit form
-- for too long, so it may make more sense to say that the edit form expired
-- rather than the token.
YOUR_POST_TOKEN_HAS_EXPIRED = {
   en_US = "Your edit form has expired.",
   es_VE = "Su edición ha expirado,"
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
   es_VE = "Vista previa de cambios <b>no guardados</b>",
}

-- A link to the part of the form where the user can change the content (used in the Preview mode).
CHANGE = {
   en_US = "change",
   ru    = "изменить",
   pt_BR = "Modificar",
   es_VE = "Modificar",
}

-- The label for the "preview" button in the edit forms. 
PREVIEW = {
   en_US = "preview",
   ru    = "посмотреть",
   pt_BR = "Visualizar",
   es_VE = "Vista previa",
}

-- The label for the "save" button in the edit forms. 
SAVE = {
   en_US = "save",
   ru    = "сохранить",
   pt_BR = "Guardar",
   es_VE = "Guardar",
}

-- The label for the "cancel" button in the edit forms. 
CANCEL = {
   en_US = "cancel",
   ru    = "отменить",
   pt_BR = "Cancelar",
   es_VE = "Cancelar",
}


-----------------------------------------------------------------------------
-----  DIFFING  -------------------------------------------------------------
-----------------------------------------------------------------------------

-- In diff mode, this is the phrase introducing the user name of the first author
BY_AUTHOR1 = {
   en_US = "by $if_link_to_author1[====[<a $link>]====]$author1$if_link_to_author1[====[</a>]====] on $date1 at $time1",
   ru    = "(автор: $if_link_to_author1[====[<a $link>]====]$author1[====[</a>]====], время: $date1, $time1)", 
   pt_BR = "por $if_link_to_author1[====[<a $link>]====]$author1[====[</a>]====] ($date1, $time1)",
   es_VE = "por $if_link_to_author1[====[<a $link>]====]$author1[====[</a>]====] ($date1, $time1)",
}

-- In diff mode, this is the phrase introducing the user name of the second author
BY_AUTHOR2 = { "by $author2",
   en_US = "by $if_link_to_author1[====[<a $link>]====]$author1$if_link_to_author2[====[</a>]====] on $date2 at $time2",
   ru    = "(автор: $if_link_to_author1[====[<a $link>]====]$author2[====[</a>]====], время: $date2, $time2)", 
   pt_BR = "por $if_link_to_author1[====[<a $link>]====]$author2[====[</a>]====] ($date2, $time2)",
   es_VE = "por $if_link_to_author1[====[<a $link>]====]$author2[====[</a>]====] ($date2, $time2)",
}


-----------------------------------------------------------------------------
-----  CHECKING LUA CODE  ---------------------------------------------------
-----------------------------------------------------------------------------

-- A message saying that a chunk of Lua code parses correctly.
THIS_LUA_CODE_PARSES_CORRECTLY = {
   en_US = "This Lua code parses correctly.",
   es_VE = "Este código Lua se interpreta correctamente.",
}

-- A message saying that a chunk of Lua fails to parse.
THIS_LUA_CODE_HAS_PROBLEMS = {
   en_US = "This Lua code has some problems:",
   es_VE = "Este código Lua tiene algunos problemas:",
}

-----------------------------------------------------------------------------
-----  RECENT EDITS  --------------------------------------------------------
-----------------------------------------------------------------------------

RECENT_EDITS_TO_SITE = {
   en_US = "Recent edits to $site_title",
   es_VE = "Ediciones recientes a $site_title",
}

RECENT_EDITS_TO_NODE = {
   en_US = "Recent edits to $site_title: $title",
   es_VE = "Ediciones recientes a $site_title: $title",
}

RSS_FOR_EDITS_TO_THIS_WIKI = {
   en_US = "RSS for edits to this wiki",
   ru    = "RSS-лента изменение этой вики",
   es_VE = "RSS para ediciones de esta wiki",
}

RSS_FOR_EDITS_TO_THIS_NODE = {
   en_US = "RSS for edits to this node",
   ru    = "RSS-лента изменение этой станицы",
   es_VE = "RSS para ediciones de este nodo",
}

RSS = RSS_FOR_EDITS_TO_THIS_NODE

BUTTON = {
   en_US = "Button",
   ru    = "Кнопка",
   es_VE = "Botón",
}

EDIT_FORM_HTML_META_KEYWORDS = {
   en_US = "HTML/Meta/Keywords",
}

EDIT_FORM_HTML_META_DESCRIPTION = {
   en_US = "HTML/Meta/Description",
}

EDIT_FORM_REDIRECT_DESTINATION = {
	en_US = "Redirect",
	es_VE = "Redirección",
}

-----------------------------------------------------------------------------
-----  REGISTRATION  --------------------------------------------------------
-----------------------------------------------------------------------------

-- Informs a user that registration is not available. (Users normally wouldn't
-- see this, since the link to the registration page would not be shown to them.)
REGISTRATION_IS_DISABLED = {
   en_US = "Sorry, registration of new users is not currently allowed."
}

-- User agrees to terms of service.
I_AGREE_TO_TERMS_OF_SERVICE = {
   en_US = "I have read to and agree to the <a href='$url' target='_blank'>Terms of Service</a><br />",
   es_VE = "He leido y acepto los <a href='$url' target='_blank'>Términos de servicio</a><br />"
}

-- Subject for the account activation email
ACCOUNT_ACTIVATION = {
   en_US = "Account activation",
   es_VE = "Activación de cuenta"
}

-- The body of the account activation email
ACTIVATION_MESSAGE_BODY = {
   en_US = [[
In order to activate your account at $site_name, please click the following link.
If the link isn't clickable, please copy and paste the URL into your web browser.
You will be asked to confirm the registered information.

$link

Thank you!
]],
   es_VE = [[
Para activar su cuenta en $site_name, por favor haga click en el siguiente link.
Si no puede hacer click en el link, por favor copie y pegue la URL en su navegador.
Se le pedirá que confirme la información registrada.

$link

Gracias.
]]
}

INVALID_ACTIVATION_TICKET = {
   en_US = "This activation ticket is invalid."
}

CLICK_HERE_TO_RESET_PASSWORD = {
   en_US = "Forgot your password? You can reset it <a $link>here</a>",
}

PASSWORD_RESET_REQUEST = {
   en_US = "Password reset request"
}

PASSWORD_RESET = {
   en_US = "Password reset"
}

-- The body of the account activation email
PASSWORD_RESET_MESSAGE_BODY = {
   en_US = [[
In order to reset the password for your account at $site_name, please click the following link.
If the link isn't clickable, please copy and paste the URL into your web browser.

$link

Thank you!
]]
}

ERROR_SENDING_ACTIVATION_EMAIL = {
   en_US = "Sorry, there was a problem sending your activation email.",
   es_VE = "Lo sentimos, hubo un problema enviando su correo de activación."
}

ERROR_SENDING_PASSWORD_RESET_EMAIL = {
   en_US = "Sorry, there was a problem sending your password reset email."
}

ACTIVATION_MESSAGE_SENT = {
   en_US = [[ An activation message was sent to your email address.
              Please check your email in a few minutes and use the link in the message to activate your account.]],
   es_VE = [[ Un mensaje de activación fue enviado a su dirección de correo electrónico.
              Por favor revise su correo electrónico, utilice el link en el mensaje para activar su cuenta.]]

}

PASSWORD_RESET_MESSAGE_SENT = {
   en_US = [[ A message was sent to your email address.  
              Please check your email in a few minutes and use the link in the message to reset your password.]]
}

INVALID_PASSWORD_RESET_TICKET = {
   en_US = [[This password reset ticket is invalid.]]
}

PASSWORD_RESET_TICKET_EXPIRED = {
   en_US = [[This password reset ticket has expired.]]
}



-- Form label for new user name
EDIT_FORM_NEW_USERNAME = {
   en_US = "User name",
   es_VE = "Nombre de usuario",
}

EDIT_FORM_USERNAME = {
   en_US = "User name"
}


-- Form label for new password
EDIT_FORM_NEW_PASSWORD = {
   en_US = "Password",
   es_VE = "Contraseña",
}

EDIT_FORM_NEW_EMAIL = {
   en_US = "Email"
}

EDIT_FORM_EMAIL = {
   en_US = "Email",
   es_VE = "Correo electrónico",
}

-- Form label for terms of service
EDIT_FORM_AGREE_TOS = {
   en_US = "Terms of Service",
   es_VE = "Términos de servicio",
}


-- Form label for confirming new password

EDIT_FORM_NEW_PASSWORD_CONFIRM = {
   en_US = "Confirm Password",
   es_VE = "Confirmar contraseña",
}

CONFIRM = {
   en_US = "confirm"
}

TWO_VERSIONS_OF_NEW_PASSWORD_DO_NOT_MATCH = {
   en_US = "Two version of the new password do not match.",
   es_VE = "Las contraseñas introducidas no concuerdan.",
}

EMAIL_DOES_NOT_MATCH_ACCOUNT = {
   en_US = "The email address you entered does not match the one on this account."
}

NEW_EMAIL_NOT_VALID = {
   en_US = "The email you entered is not valid.",
   es_VE = "El correo que introdujo no es válido."
}

MUST_CONFIRM_TOS = {
   en_US = "You must agree to the terms of service in order to create a new account.",
   es_VE = "Debe aceptar los términos de servicio para crear una nueva cuenta.",
}

USERNAME_TAKEN = {
   en_US = "This user name is already taken.",
   es_VE = "El nombre de usuario ya existe."
}

INCORRECT_USERNAME = {
   en_US = "Please check the username."
}

SUCCESSFULLY_CREATED_ACCOUNT = {
   en_US = "Successfully created your new account.",
   es_VE = "Se ha creado su cuenta exitosamente."
}

SUCCESSFULLY_CREATED_USER_NODE = {
   en_US = "Successfully created your profile node."
}

COULD_NOT_CREATE_USER_NODE = {
   en_US = "Could not create your profile node."
}

SUCCESSFULLY_CHANGED_PASSWORD = {
   en_US = "Your password has been reset."
}

PLEASE_CONFIRM_PASSWORD = {
   en_US = "Please confirm the new password",
   es_VE = "Por favor confirme su nueva contraseña"
}

PLEASE_CHOOSE_NEW_PASSWORD = {
   en_US = "Please choose a new password",
}

AUTH_MODULE_DOES_NOT_SUPPORT_PASSWORD_RESET = {
   en_US = "The current authentication module does not support password reset.",
}

COULD_NOT_CONFIRM_NEW_PASSWORD = {
   en_US = "The password you entered is different from the one given originally.",
   es_VE = "La contraseña que introdujo es diferente a la que introdujo originalmente."
}



-----------------------------------------------------------------------------
-----  CAPTCHA  --------------------------------------------------------
-----------------------------------------------------------------------------

COULD_NOT_VERIFY_CAPTCHA = {
   en_US = "Could not verify captcha: ",
   es_VE = "No se pudo verificar el captcha: "
}

-- A note telling the user that they need to enter captcha because they are not logged in.
ANONYMOUS_USERS_MUST_ENTER_CAPTCHA = {
   en_US = "Anonymous users must enter <a href='http://en.wikipedia.org/wiki/Captcha'>captcha</a> below.",
   es_VE = "Los usuarios anónimos deben introducir el <a href='https://es.wikipedia.org/wiki/Captcha'>captcha</a> a continuación."
}

NO_SUCH_NODE = {
   en_US = "This node by this name does not exist.",
   es_VE = "Este nodo no existe."
}

PLEASE_PICK_A_TYPE_TO_CREATE_A_NEW_NODE = {
   en_US = [[The node by this name does not exist, but you can create it.
             Please pick one of the node types below.]],
   es_VE = [[Este nodo no existe, pero puede crearlo.
             Por favor elija uno de los tipos de nodo a continuación.]]
}

THIS_NODE_DOES_NOT_EXIST_BUT_YOU_CAN_CREATE_IT = {
   en_US = [[The node by this name does not exist, but you can create it.]]
}

THIS_NODE_IS_MARKED_DELETED = {
   en_US = [[This node has been marked as deleted.]]
}

YOU_MAY_BE_ABLE_TO_UNDELETE_THIS_NODE = {
   en_US = [[ You may be able to undelete it under "Advanced Fields" in the edit
              form. ]]
}

CREATE_A_BASIC_NODE = {
   en_US = [[Create a basic node.]]
}

OR_SELECT_ANOTHER_NODE_TYPE = {
   en_US = [[Or pick one of the other node types below.]]
}

THIS_PAGE_DEFINED_THE_FOLLOWING_ACTIONS = {
   en_US = "This node supports the following commands:",
   es_VE = "Este nodo soporta los siguientes comandos:"
}

-----------------------------------------------------------------------------
-----  RSS OUTPUT  --------------------------------------------------------
-----------------------------------------------------------------------------

NO_EDIT_SUMMARY = {
   en_US = "No edit summary provided",
   es_VE = "No se ha proporcionado sumario de edición",
}

ANONYMOUS_USER = {
   en_US = "Anonymous user",
   es_VE = "Usuario anónimo",
}

-----------------------------------------------------------------------------
-----  COMMENTS AND FORUMS  -------------------------------------------------
-----------------------------------------------------------------------------

REPLY = {
   en_US = "Reply",
   pt_BR = "Responder",
   ru = "Ответить",
   es_VE = "Responder"
}

QUOTE = {
   en_US = "Quote",
   ru = "Цитировать",
   es_VE = "Cita"
}

ADD_NEW_DISCUSSION_TOPIC = {
   en_US = "Add new discussion topic",
   ru = "Добавить тему",
   es_VE = "Agregar nuevo tema de discusión"
}

]=============]
