require 'wiringpi'

INPUT  = 0
OUTPUT = 1

class Gpio

	@@pins = [
		0,1,2,3,4,5,6,7, # basic IO pins
		10,11,12,13,14,	 # SPI pins, can also be used for IO
		8,9,			 # i2c with 1k8 pull up resistor
        15,16,17
		]

	@@init = false

	def self.readAll

		self.wiringPiSetup unless @@init

		pinValues = Hash.new

		@@pins.each do |pin|
		
			pinValues[pin] = self.read(pin)
		
		end

		pinValues

	end

	def self.wiringPiSetup

		Wiringpi.wiringPiSetup
		@@init = true
	
	end

	def self.read(pin)

		self.wiringPiSetup unless @@init

		raise ArgumentError, "invalid pin, available gpio pins: #{@@pins}" unless @@pins.include?(pin)

		Wiringpi.digitalRead(pin)

	end

	def self.write(pin,value)

		self.wiringPiSetup unless @@init
	
		raise ArgumentError, "invalid pin, available gpio pins: #{@@pins}" unless @@pins.include?(pin)
		raise ArgumentError, 'invalid value' unless [0,1].include?(value)

		Wiringpi.digitalWrite(pin,value)

		#output.chop!

	end

	def self.mode(pin,mode)

		self.wiringPiSetup unless @@init

		raise ArgumentError, "invalid pin, available gpio pins: #{@@pins}" unless @@pins.include?(pin)
		raise ArgumentError, "invalid mode" unless [INPUT,OUTPUT].include?(mode)

		Wiringpi.pinMode(pin, mode)

	end

end
