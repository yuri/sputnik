module(..., package.seeall)

MONTHS = { 
   {"Jan", 31}, {"Feb", 28}, {"Mar", 31}, {"Apr", 30}, 
   {"May", 31}, {"Jun", 30}, {"Jul", 31}, {"Aug", 31}, 
   {"Sep", 30}, {"Oct", 31}, {"Nov", 30}, {"Dec", 31} 
}

Calendar = {}

function Calendar:new() 
   local o = {}
   setmetatable(o, self)
   self.__index = self
   return o  
end

function today() 
   local d = os.date("*t")
   return string.format("%04d-%02d-%02d", d.year, d.month, d.day)
end

function Calendar:select_date(date)
   self.yyyy_mm = date:sub(1,7)
   self.yyyy = date:sub(1,4)
   self.mm = date:sub(6,7)
   self.dd = date:sub(9,11)

   if self.mm:len() > 0 then 
      self.month_as_number = tonumber(self.mm)
   else
      self.month_as_number = 1 
      self.mm = "01"
   end 
   if self.dd:len() > 0 then 
      self.date_as_number = tonumber(self.dd) 
   else
      self.date_as_number = 1
      self.dd = "01"
   end
end

function Calendar:get_months_of_the_year() 
   local months = {}
   for m=1,12 do
      if m==self.month_as_number then
         table.insert(months, 1)
      else 
         table.insert(months, 0)
      end
   end
   return months
end

function Calendar:get_days_of_the_month() 
   local days = {}
   for d=1,MONTHS[self.month_as_number][2] do
      if d==self.date_as_number then
         table.insert(days, 1)
      else 
         table.insert(days, 0)
      end
   end
   return days
end

function Calendar:day_of_this_month_to_string(day) 
   return string.format("%s-%s-%02d", self.yyyy, self.mm, day)
end

function Calendar:month_of_this_year_to_string(month) 
   return string.format("%s-%02d", self.yyyy, month)
end

