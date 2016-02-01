require 'redis'
#require 'mongo'
require 'serialport'
require 'json'
#require_relative 'nodes/node'

module Frutas

  class Receive
    @port = nil
    @db = nil
    @db_name = nil
    @last_station = nil

    #@nodes = []

    def initialize port, baud
      #port = '/dev/ttyUSB0' if port.nil?
      port = '/dev/ttyACM0' if port.nil?
      baud = 9600 if baud.nil?
      begin
        @port = SerialPort.new(port.to_s, baud);
        @db = Redis.new(:host => 'localhost', :port => 6379)
        #@db.connect "127.0.0.1", 6379
        @db_name = 'pri_nodes'
        @db.del @db_name #clear the list of reported nodes
      rescue Exception => e
        puts 'Ocurrió un error conectando al puerto serial o al servicio de Redis'
        puts e.message
        exit 1
      end
    end

    def run
      loop do
        file = File.open('registro.txt', 'w+')
        data = @port.gets
        data = data.to_s.chomp # elimina salto de carro y nueva linea
        #puts data.class
        #puts "DATA: #{data}"
        if data.class != NilClass or data != ""
          if (/([a-zA-Z])\w+;([a-zA-Z])\w+/ =~ data.to_s) != nil 
            #puts 'hola'   
            cmd = decode_cmd data
            if cmd[:cmd] == 'conectar'
              file.puts "Conectando a #{cmd[:station]}"
              puts "Conectando a #{cmd[:station]}"
              @last_station = cmd[:station]
              @port.write "enviar;#{cmd[:station]}"
              puts "enviar;#{cmd[:station]}"
              sleep 20
            end
          #elsif (/([a-zA-Z])\w+:(([0-9])\w+(.?[0-9]));?/ =~ data.to_s) != nil
          elsif (/(([A-z0-1])\w+:([0-9])\w+(\.[0-9])?;)+/ =~ data.to_s) != nil
            d = format_json(data)
            puts d
            file.puts d
            puts Time.now()
            file.puts Time.now()
            @port.write "ok;#{@last_station}"
            file.puts "--------------"
            update_nodes(@last_station, d)
          end
        end
        sleep 1
        file.close
      end
    end

    def decode_cmd data
      arr_kv = data.split(';')
      return { :cmd => arr_kv[0].to_s, :station => arr_kv[1]}
    end

    def format_json data
      arr_kv = data.split(';')
      data = {}
      arr_kv.each do |kv|
        a = kv.split(':')
        if a[1].include? '.'
          data[a[0].to_sym] = a[1].to_f
        else
          data[a[0].to_sym] = a[1].to_i
        end
      end

      data[:time] = Time.now.to_s

      return data.to_json#JSON.generate(data)
    end

    def insert_data data
      data = format_json(data)
      #@db.write ["LPUSH", @db_name, data]
      #puts @db.read
      puts data
    end

    def update_nodes name, data
      @db.hset 'pri_nodes', name, data
    end

  end
end

#r = Frutas::Receive.new '/dev/ttyUSB0', 57600
r = Frutas::Receive.new 'COM3', 57600
r.run

