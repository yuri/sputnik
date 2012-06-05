module(..., package.seeall)

require ("pod")

function new(sputnik) 
   return {
      transform = function(text)
                     return pod.parserToBuffer (text, sputnik.config.NICE_URL, true)
                   end
   }
end
