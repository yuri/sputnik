
module(..., package.seeall)


SputnikMarkup = {
   markup = nil,      -- The markup module
}


--- Creates a new instance of SputnikMarkup.
--
--  @param  markup       A markup module.
--  @return              An instance of SputnikMarkup.

function SputnikMarkup.new(self, markup)
   obj = {}
   obj.markup = markup
   setmetatable(obj, self)
   self.__index = self
   return obj         
end


--- Wikify a text string
--
--  @param text          The original text
--  @param templates     Templates of the page 
--  @param base_rul      The base url when resolving links
--  @return              The text wikified.

function SputnikMarkup.wikify_text (self, text, templates, base_url, helpers) 
	return self.markup:wikify_text (text, templates, base_url, helpers)
end


--- Returns an instance of SputnikMarkup.
--
--  @param markup        A markup module to be used
--  @return              An instance of SputnikMarkup.

function open(markup) 
   return SputnikMarkup:new(markup) 
end


