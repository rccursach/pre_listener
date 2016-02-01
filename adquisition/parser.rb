
module PRI_FRUTAS

  ##
  # Decodes data from PRI_FRUTAS nodes
  #
  class Parser

    ##
    # Returns cmd string as Hash
    #
    def decode_cmd data
      arr_kv = data.split(';')
      return { :cmd => arr_kv[0].to_s, :node_name => arr_kv[1]}
    end


    ##
    # Returns data string as Hash
    #
    def decode_data data
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
      return data
    end

  end
end