(ns qbits.tape.test.test-logger
  (:require
   [qbits.tape :as tape]
   [pixie.test :as t]
   [pixie.async :as async]))

(t/deftest test-logging
  (let [sys (tape/example-system {:levels #{:info :error}})]
    (prn sys)
    (dotimes [i 100]
      (async/future (tape/log (:loggerA sys) :info (str ":one " i)))
      (async/future (tape/info (:loggerA sys) (str ":two " i)))
      (async/future(tape/warn (:loggerA sys) (str ":three" i)))
      (async/future (tape/log (:loggerA sys) :error (str ":four" i))))
    @(async/promise)))
