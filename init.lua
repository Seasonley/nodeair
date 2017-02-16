--家庭空气质量管家
--sensor为传感器data口
--power为继电器控制口
--D0    CH1             0
--D1    CH2             0
--D2    CH4             0
--D3    MQ-DATA  1
--D4    DHT-DATA 0
--D5    CH3             0
--D6    DHT-VCC    1
--RX    PM-TX
Air={
    pm010=0,pm025=0,pm100=0,
    temp=0,humi=0,smoke=1,
    gpio_pm=0,gpio_temp=0,gpio_humi=0,gpio_smoke=0,
    humi_power=0, pm_power=1,
    smoke_power=2,   mq_sensor=3,
    dht_sensor=4,    temp_power=5
}
--引脚初始化
for pi=0,6,1 do
    gpio.mode(pi, gpio.OUTPUT,(pi==6)and gpio.PULLUP or gpio.FLOAT)
    gpio.write(pi,(pi==3 or pi==6)and gpio.HIGH or gpio.LOW)
end
--网络
wifi.setmode(wifi.STATION)
wifi.sta.config("SSID","PASSWORD")
--串口监听
uart.setup( 0, 9600, 8, 0, 1, 0 )
uart.on("data",
  function(data)
    if(string.len(data)==32 and string.byte(data)==66) then
        --颗粒
        Air.pm010=tonumber(string.byte(data,11))*256+tonumber(string.byte(data,12))
        Air.pm025=tonumber(string.byte(data,13))*256+tonumber(string.byte(data,14))
        Air.pm100=tonumber(string.byte(data,15))*256+tonumber(string.byte(data,16))
        --温湿度
        _,Air.temp,Air.humi, _, _ =dht.read(Air.dht_sensor)
        --烟雾
        Air.smoke=gpio.read(Air.mq_sensor)
        --继电器
        Air.gpio_pm,Air.gpio_temp,Air.gpio_humi,Air.gpio_smoke=gpio.read(Air.pm_power),gpio.read(Air.temp_power),gpio.read(Air.humi_power),gpio.read(Air.smoke_power)
    end
end, 0)
--http
srv=net.createServer(net.TCP)  
srv:listen(80,function(conn)  
    conn:on("receive", function(client,request)  
        local buf = "{"
        local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP")
        if(method == nil)then  
            _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP")
        end  
        local _GET = {}  
        if (vars ~= nil)then  
            for k, v in string.gmatch(vars, "(%w+)=(%w+)&*") do  
                _GET[k] = v  
            end  
        end  
        if(_GET.action == "read")then
            for key,value in pairs(Air) do
                buf=buf..key..":"..value..","
            end
        elseif(_GET.action == "write")then
              gpio.write(_GET.pin,_GET.level)
        elseif(_GET.action == "debug")then
              node.input(_GET.data)
        end  
        client:send(buf.."error:0}")
        client:close()
        collectgarbage()
    end)  
end)  
