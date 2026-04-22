--- @class LogSystem
--- 日志系统组件
local LogSystem = {}

LogSystem.propertys = {
    ShowTimestamp = {
        type = Mini.Bool,
        default = true,
        displayName = "显示时间戳",
        sort = 1,
        tips = "开启后将在日志前显示当前系统时间"
    }
}

LogSystem.openFnArgs = {
    Debug = {
        displayName = "输出调试",
        params = {Mini.String, Mini.String}
    },
    Info = {
        displayName = "输出信息",
        params = {Mini.String, Mini.String}
    },
    Warn = {
        displayName = "输出警告",
        params = {Mini.String, Mini.String}
    },
    Error = {
        displayName = "输出错误",
        params = {Mini.String, Mini.String}
    }
}

--- 日志等级映射表
local _LEVELS = {
    DEBUG = 1,
    INFO = 2,
    WARN = 3,
    ERROR = 4
}

--- 组件初始化入口
--- @return nil
function LogSystem:OnStart()
    self.ShowTimestamp = self.ShowTimestamp or true
end

--- 输出调试级别日志
--- @param message any @日志内容
--- @param funcName? string @调用函数名称
--- @return nil
function LogSystem:Debug(message, funcName)
    self:_OutputLog(_LEVELS.DEBUG, "DEBUG", message, funcName)
end

--- 输出信息级别日志
--- @param message any @日志内容
--- @param funcName? string @调用函数名称
--- @return nil
function LogSystem:Info(message, funcName)
    self:_OutputLog(_LEVELS.INFO, "INFO", message, funcName)
end

--- 输出警告级别日志
--- @param message any @日志内容
--- @param funcName? string @调用函数名称
--- @return nil
function LogSystem:Warn(message, funcName)
    self:_OutputLog(_LEVELS.WARN, "WARN", message, funcName)
end

--- 输出错误级别日志
--- @param message any @日志内容
--- @param funcName? string @调用函数名称
--- @return nil
function LogSystem:Error(message, funcName)
    self:_OutputLog(_LEVELS.ERROR, "ERROR", message, funcName)
end

--- 内部日志输出处理函数
--- @param level number @当前日志等级
--- @param levelName string @等级名称标识
--- @param message any @日志内容
--- @param funcName? string @调用函数名称
--- @return nil
function LogSystem:_OutputLog(level, levelName, message, funcName)
    local content = tostring(message)
    local timePrefix = ""
    if self.ShowTimestamp and os and os.date then
        timePrefix = string.format("[%s]", os.date("%H:%M:%S"))
    end

    if funcName then
        content = string.format("%s -> %s", funcName, content)
    end

    local finalLog = string.format("%s [%s] %s", timePrefix, levelName, content)

    if level >= _LEVELS.ERROR then
        printError(finalLog)
    else
        print(finalLog)
    end
end

-- 创建元表用于保护组件原型, 阻止外部直接修改私有成员
local _ProtectMT = {
    --- 索引访问元方法
    --- @param t table @被访问的表
    --- @param k string @访问的键名
    --- @return any @返回对应的值
    __index = function(t, k)
        return rawget(LogSystem, k)
    end,
    --- 新索引赋值元方法
    --- @param t table @被赋值的表
    --- @param k string @赋值的键名
    --- @param v any @赋值的值
    --- @return nil
    __newindex = function(t, k, v)
        -- 允许修改公有属性（不以_开头的字符串键）
        if type(k) == "string" and k:sub(1, 1) ~= "_" then
            rawset(t, k, v)
        else
            -- 阻止修改私有成员并输出错误日志
            printError(string.format("Protected: cannot modify private member '%s'", tostring(k)))
        end
    end
}

-- 应用元表保护到组件原型
setmetatable(LogSystem, _ProtectMT)

return LogSystem