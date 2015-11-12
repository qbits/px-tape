(ns qbits.tape.test.test-logger
  (:require
   [qbits.tape :as tape]
   [pixie.test :as t]
   [pixie.async :as async]))

(t/deftest test-logging
  (let [sys (tape/example-system {:levels #{:info :error}})]
    (dotimes [i 1000]
      (tape/log (:loggerA sys) :info (str ":one " i))
      (tape/info (:loggerA sys) (str ":two " i))
      (tape/warn (:loggerA sys) (str ":three" i))
      (tape/log (:loggerA sys) :error (str ":four" i)))

    (dotimes [i 1000]
      (tape/log (:loggerB sys) :info (str ":fone " i))
      (tape/info (:loggerB sys) (str ":ftwo " i))
      (tape/warn (:loggerB sys) (str ":fthree" i))
      (tape/log (:loggerB sys) :error (str ":ffour" i)))

    (dotimes [i 1000]
      (tape/log (:loggerC sys) :info (str ":cone " i))
      (tape/info (:loggerC sys) (str ":ctwo " i))
      (tape/warn (:loggerC sys) (str ":cthree" i))
      (tape/log (:loggerC sys) :error (str ":cfour" i)))

    @(async/promise)
    ))
