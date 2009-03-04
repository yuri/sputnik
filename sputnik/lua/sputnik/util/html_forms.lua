module(..., package.seeall)

require("saci.sandbox")

function compile_field_spec(field_spec)
   local fields, field_names = {}, {}
   local sandbox = saci.sandbox.new()
   sandbox:do_lua(field_spec)
   for name, spec in pairs(sandbox.values) do
      spec.name = name
      table.insert(fields, spec)
      table.insert(field_names, name)
   end

   return fields, field_names
end

function make_html_form(form_params, fields, field_names)
   -- Compile the field_spec if it hasn't already been compiled
   if not fields or not field_names then
      fields, field_names = compile_field_spec(form_params.field_spec)
   end

   table.sort(fields, function(x,y) return x[1] < y[1] end) -- sort by the first value (position)
   
   local form_decorators = {
      checkbox = function(field)
                    local isset = field.value
                    if type(isset)=="string" then isset = isset:len() > 0 end
                    field.if_checked = cosmo.c(isset){}
                    field.inline = true
                 end,
      checkbox_text = function(field)
         local isset = field.value
         if type(isset)=="string" then isset = isset:len() > 0 end
         field.if_checked = cosmo.c(isset){}
         field.inline = true
      end,
      div_start = function(field)
         field.no_label = true
         field.class = "collapse"

         function field.do_collapse()
            cosmo.yield{
               state = field.open and "open" or "closed",
            }
         end
      end,
      div_end = function(field)
         field.no_label = true
      end,
      header   = function(field) field.no_label = true; end,
      note     = function(field) field.no_label = true; end,
      text_field = function(field)
                    field.inline = true
                 end,
      password = function(field)
                    field.inline = true
                 end,
      readonly_text = function(field)
                    field.inline = true
                 end,
      textarea = function(field) 
                    local num_lines = 0
                    string.gsub(field.value, "\n", function() num_lines = num_lines + 1 end)
                    if num_lines > 10 then num_lines = 10 end
                    field.rows = field.rows or 3
                    field.cols = field.cols or 80
                    field.rows = num_lines + field.rows
                 end,
      file     = function(field)
                    field.inline = true
                 end,
      select   = function(field)
                    field.inline = true
                    field.do_options = function()
                       for idx,entry in ipairs(field.options) do
                          local display, value
                          if type(entry) == "table" then
                             display = entry.display
                             value = entry.value or display
                          else
                             display = entry
                             value = entry
                          end

                          cosmo.yield{
                             display = display,
                             value = value,
                             if_selected = cosmo.c(value == field.value){}
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
      local template   = form_params.templates["EDIT_FORM_"..field_type:upper()]
      
      field.label = form_params.translator.translate_key("EDIT_FORM_"..name:upper())

      field.name   = form_params.hash_fn(name)
      field.anchor = name
      field.html = ""
      field.div_class = field.div_class or ""
      field.tab_index = i
      field.class = field.class or ""

      if not (field.value == false) then
         field.value = field.value or form_params.values[name]
      end

      if form_decorators[field_type] then
         form_decorators[field_type](field)
      end

      if not field.no_label then
         if field.inline then
            field.html = cosmo.fill(form_params.templates.EDIT_FORM_INLINE_LABEL, field)
         else
            field.html = cosmo.fill(form_params.templates.EDIT_FORM_LABEL, field)
         end
      end
      field.html = field.html..cosmo.fill(template, field)

      if field_type == "div_start" or field_type == "div_end" then
         html = html .. field.html
      else
         field.div_class = field.div_class.." ctrlHolder"
         if field.advanced then
            field.div_class = field.div_class.." advanced_field"
         end
         if field_type ~= "header" then
            field.div_class = field.div_class.." field"
         end
         html = html.."       <div class='"..field.div_class.."'>"..field.html.."       </div>\n"
      end
   end
   return html, field_names
end

-- vim:ts=3 ss=3 sw=3 expandtab
