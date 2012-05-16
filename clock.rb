require './gpio.rb'

# Alias GPIO pins using constants
# Sorry for my cryptic shorthand constant names

# Binary hours
LEDH16	= 10 # hours 16
LEDH8	= 11 # hours 8
LEDH4	= 14 # hours 4
LEDH2	= 12 # hours 2
LEDH1   = 6  # hours 1

# Binary minutes
LEDM32	= 4	 # mins 32
LEDM16	= 3	 # mins 16
LEDM8	= 2	 # mins 8
LEDM4	= 0	 # mins 4
LEDM2	= 1	 # mins 2
LEDM1	= 7	 # mins 1

# Binary days
LEDD4   = 13 # days 4
LEDD2   = 9  # days 2
LEDD1   = 8  # days 1

# Just so we don't get confused!
ON		= 1
OFF		= 0

class Clock

    # Collect all our lovely LEDs into a manageable array
	@@myleds = [
	LEDH16,
	LEDH8,
	LEDH4,
	LEDH2,
    LEDH1,

	LEDD4,
    LEDD2,
    LEDD1,

	LEDM32,
	LEDM16,
	LEDM8,
	LEDM4,
	LEDM2,
	LEDM1
	]

    # Group our day LEDs together
    @@mydays = {
    4  => LEDD4,
    2  => LEDD2,
    1  => LEDD1
    }

    # Goup our hour LEDs together
	@@myhours = {
    16 => LEDH16,
	8  => LEDH8,
	4  => LEDH4,
	2  => LEDH2,
	1  => LEDH1
	}

    # Group our minute LEDs together
	@@mymins = {
	32 => LEDM32,
	16 => LEDM16,
	8  => LEDM8,
	4  => LEDM4,
	2  => LEDM2,
	1  => LEDM1
	}

    # Keep track of our running state 
	@@running = false

    # Start the clock
	def self.go!

        # We're running, whee!
		@@running = true

		ledsSetup!
		ledsTest		

        # Our main loop, will run until @@running = false
		while @@running

			time = Time.new

			hour = time.hour
			min  = time.min
            day  = time.wday
		
            # The \r will keep refreshing the same line in the terminal, showing the time
			STDOUT.write "\r" + time.to_s

            # We want to animate the LEDs somewhat
			slept = 0       # So keep track of how long we've delayed for
            delay = 0.05    # And delay each LED a little for a cool effect

            # Loop through each day LED, getting its binary number and LED pin
            @@mydays.each do |number,led|

                # If the day nuber is greater than the current number then...
                if day >= number

                    Gpio.write(led,ON) # Light that LED!
                    day = day - number # Subtract the current number from our day

                    # ... leaving the remainder to light other LEDs

                    sleep(delay)            # Cool effect, remember!
                    slept = slept + delay   # Keep track of how long we've slept for

                end

                break unless day > 0        # There's no LED for 0, so exit if we hit it

            end

            # As above except for hours
			@@myhours.each do |number,led|

				if hour >= number

					Gpio.write(led,ON)
					hour = hour - number

					sleep(delay)
					slept = slept + delay

				end

				break unless hour > 0

			end

			# As above except for minutes
            @@mymins.each do |number,led|

				if min >= number

					Gpio.write(led,ON)
					min = min - number

					sleep(delay)
					slept = slept + delay

				end

				break unless min > 0

			end

            # Sleep for one second, minus the time we delayed
            # This should, hopefully, flash the LEDs on for a second
			sleep(1-slept)

            # Turn all the LEDs off again
			@@myleds.each do |led|
		
				Gpio.write(led,OFF)

			end

            # Sleep for another second with the LEDs off
			sleep(1)

		end

	end

	def self.ledsSetup!

        # Set all our LED modes to OUTPUT ( constant of 1 found in gpio.rb )
		@@myleds.each do |led|
			Gpio.mode(led,OUTPUT)
		end	

	end

	def self.ledsTest

        # Test all the LEDs are present and in the correct order
        # The following code is just loops and simple logic to 
        # flash the LEDs in pretty but mosrly useless patterns

		lastled = nil
		delay	= 0.04

		@@myleds.each{ |led| Gpio.write(led,ON) }
		sleep(1)
		@@myleds.each{ |led| Gpio.write(led,OFF) }		

		4.times do |step|

			@@myleds.each_index do |index|
				
				led = @@myleds[index]

				if step % 2 == 0
					Gpio.write(led,ON)		unless index % 2 == 0
					Gpio.write(led,OFF)	    if	   index % 2 == 0
				else
					Gpio.write(led,ON)		if 	   index % 2 == 0
					Gpio.write(led,OFF)	    unless index % 2 == 0
				end

			end
			sleep(0.1)

		end # End n.times do

		2.times do
		    @@myleds.each do |led|

			    Gpio.write(lastled,	OFF) unless lastled.nil?
			    Gpio.write(led,		ON)
		    	lastled = led
			    sleep( delay )	

		    end
	    	@@myleds.reverse.each do |led|

		    	Gpio.write(lastled,	OFF) unless lastled.nil?
		    	Gpio.write(led,		ON)
		    	lastled = led
		    	sleep( delay )

	    	end
		Gpio.write(lastled,	OFF) unless lastled.nil?
		end # End n.times do

	end

	def self.exit!

            # Handle exit gracefully

			@@running = false # Stop the clock loop
			
            STDOUT.write "\nTurning off LEDs"
			
            # Turn off all the LEDs
            @@myleds.each do |led|
				Gpio.write(led,OFF)
			end
			
            # Say Goodbye!
            STDOUT.write "\nGoodbye!\n"

            # Exit
			exit 0

	end

end

# Trap CTRL+C and exit gracefully
trap("SIGINT") { Clock.exit! }

# Go go go!
Clock.go!
