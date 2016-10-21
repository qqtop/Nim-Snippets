import cx,math,rdstdin,osproc

# quickMortgage
# 
# Input : loan amount
#         annual interest rate in pct
#         length of mortgage in years
#         payments / year assumed 12
# default values are provided for testing , just press enter



hdx(println("Welcome to quickMortgage ",randcol()))
echo()

var principal = 0.00
var percent_interest = 0.00
var myears = 0.00



# give total loan
try:
  principal = parseFloat(quoteshellposix(readLineFromStdin("Loan amount            : ")))
except:
  principal = 1100000.0
  
# give annual percent interest
try:
  percent_interest = parseFloat(quoteshellposix(readLineFromStdin("Annual interest in pct : ")))
except:
  percent_interest = 4.75
  
# give length of mortgage
try:
  myears = parseFloat(quoteshellposix(readLineFromStdin("Years                  : ")))
except:
  myears = 20.0  
  
hlineln(80)
echo()


# calculate total number of payments
var payment_number = myears * 12.0


# calculate monthly interest rate
var monthly_interest = percent_interest/(100.0 * 12.0)

var monthly_payment = principal * (monthly_interest / (1.0 - (pow(1.0 + monthly_interest,-payment_number))))

printlnBiCol("Total loan     : " & ff2(principal,2))
printlnBiCol("Interest       : " & ff2(percent_interest) & "%")
printlnBiCol("Years          : " & ff2(myears,2))
printlnBiCol("Payments       : " & ff2(payment_number,2))
printlnBiCol("Payment/month  : " & ff2(monthly_payment,2))

hlineln(80)

printlnBiCol("Total cost     : " & ff2(payment_number * monthly_payment,2))
printlnBiCol("Total interest : " & ff2(payment_number * monthly_payment - principal,2))

hlineln(80)

# give payments made
var payments = 100.0

var a = pow(1.0 + monthly_interest,payments) - 1.0
var b = pow(1.0 + monthly_interest,payment_number) - 1.0
var rem_principal = principal * (1.0 - (a / b))

printlnBiCol("Remaining principal               : " & ff2(rem_principal,2) & " after " & ff2(payments,2) & " payments" )
printlnBiCol("Paid sofar a total of             : " & ff2(monthly_payment * payments,2))
var togo = payment_number * monthly_payment - monthly_payment * payments
printlnBiCol("Still to pay principal + interest : " & ff2(togo,2))


decho(2)
println("Thank you for using quickMortgage.",randcol())
doFinish()
