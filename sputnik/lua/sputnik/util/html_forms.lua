module(..., package.seeall)

require("saci.sandbox")

function make_html_form(form_params)
   local fields = {}
   local just_field_names = {}
   local sandbox = saci.sandbox.new()
   sandbox:do_lua(form_params.field_spec) -- [[         user         = {5.1, "text_field"}]])
   --local field_table = versium.luaenv.make_sandbox().do_lua(form_params.field_spec)
   for name, spec in pairs(sandbox.values) do
      spec.name = name
      table.insert(fields, spec)
      table.insert(just_field_names, name)
   end
   table.sort(fields, function(x,y) return x[1] < y[1] end) -- sort by the first value (position)
   
   local form_decorators = {
      checkbox = function(field)
                    local isset = field.value
                    if type(isset)=="string" then isset = isset:len() > 0 end
                    field.if_checked = cosmo.c(isset){}; 
                 end,
      header   = function(field) field.no_label = true; end,
      note     = function(field) field.no_label = true; end,
      textarea = function(field) 
                    local num_lines = 0
                    string.gsub(field.value, "\n", function() num_lines = num_lines + 1 end)
                    if num_lines > 10 then num_lines = 10 end
                    field.rows = num_lines + field.rows
                 end,
      select   = function(field)
                    field.do_options = function()
                       for i, option in ipairs(field.options) do
                           cosmo.yield{
                              option=option,
                              if_selected = cosmo.c(option==field.value){}
                           }
                       end
                    end
                 end, 
      honeypot = function(field)
                    field.div_class = field.div_class.." honey"
                    field.label = form_params.translator.translate_key("EDIT_FORM_HONEY")
                 end,
   }

   local html = ""

   for i, field in ipairs(fields) do
      local field_type = field[2]
      local name       = field.name
      local label      = form_params.translator.translate_key("EDIT_FORM_"..name:upper())
      local template   = form_params.templates["EDIT_FORM_"..field_type:upper()]

      field.name   = form_params.hash_fn(name)
      field.label  = label
      field.anchor = name
      field.html = ""
      field.div_class = field.div_class or ""

      if not (field.value == false) then
         field.value = field.value or form_params.values[name]
      end

      if form_decorators[field_type] then
         form_decorators[field_type](field)
      end

      if not field.no_label then
         field.html = cosmo.fill(form_params.templates.EDIT_FORM_LABEL, field)
      end
      field.html = field.html..cosmo.fill(template, field)
      
      field.div_class = field.div_class.." ctrlHolder"
      if field.advanced then
         field.div_class = field.div_class.." advanced_field"
      end
      html = html.."       <div class='"..field.div_class.."'>"..field.html.."       </div>\n"
   end
   return html, just_field_names
end



