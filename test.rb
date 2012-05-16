require './gpio.rb'
	
    MYLEDS = [
	0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17
    ]

def doexit!

    STDOUT.write "\nTurning off LEDs"
    MYLEDS.each do |led|

        Gpio.write(led,0)        

    end
    STDOUT.write "\nGoodbye!\n"
    exit 0

end

def test!

    MYLEDS.each do |led|

        Gpio.mode(led,OUTPUT)
        Gpio.write(led,0)

    end

    MYLEDS.each do |led|

        STDOUT.write "Testing LED #{led}\n"
        Gpio.write(led,1)
        sleep(2)
        Gpio.write(led,0)
    
    end

end

trap("SIGINT") { doexit! }

test!
