module Faker
  class Preset
    class << self
      def common_apachelog
        # 71.212.224.97 - - [04/Jan/2015:05:27:35 +0000] "GET /images/jordan-80.png HTTP/1.1" 200 6146 "http://www.semicomplete.com/projects/xdotool/" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1700.107 Safari/537.36"
        #  Grok parser
        # %{IPORHOST:clientip} %{USER:ident} %{USER:auth} \[%{HTTPDATE:timestamp}\] "(?:%{WORD:verb} %{NOTSPACE:request}(?: HTTP/%{NUMBER:httpversion})?|%{DATA:rawrequest})" %{NUMBER:response} (?:%{NUMBER:bytes}|-)
        FakerFactory.once("%{internet.ip_v4_address} - - [#{::Time.new.strftime("%d/%b/%Y:%H:%M:%S %z")}] \"#{["GET POST HEAD PUT PATCH OPTIONS DELETE CONNECT"]} \"")
      end

      # COMBINEDAPACHELOG %{COMMONAPACHELOG} %{QS:referrer} %{QS:agent}
      def combined_apachelog

      end

    end
  end
end
