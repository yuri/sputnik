module(..., package.seeall)

local calendar = require("sputnik.util.calendar")

function make_date_selector(args)
   local cal = calendar.Calendar:new()
   args.current_date = args.current_date or calendar.today()
   cal:select_date(args.current_date)
   
   return cosmo.f(args.template){
             current_month = cal.mm,
             current_year  = cal.yyyy,
             do_dates      = function()
                                for d, current in ipairs(cal:get_days_of_the_month()) do
                                   cosmo.yield{
                                      if_current_date = cosmo.c(current==1){
                                                           date=d
                                                        },
                                      if_other_date   = cosmo.c(current==0){
                                                           date=d,
                                                           date_link = args.datelink(cal:day_of_this_month_to_string(d))
                                                        }
                                   }
                                end
                             end,
              do_months    = function()
                                for m, current in ipairs(cal:get_months_of_the_year()) do
                                   local month_name = calendar.MONTHS[m][1]
                                   cosmo.yield{
                                      if_current_month = cosmo.c(current==1){
                                                            month = month_name,
                                                         },
                                      if_other_month   = cosmo.c(current==0){
                                                            month = month_name,
                                                            month_link = args.datelink(cal:month_of_this_year_to_string(m))
                                                         }
                                   }
                                end
                             end,
          }
end

