(ns qbits.tape.test.test-logger
  (:require
   [qbits.tape :as tape]
   [pixie.test :as t]
   [pixie.async :as async]))

(t/deftest test-logging
  (let [logger (tape/example-system {:levels #{:info :error}})]
    (dotimes [i 100]
      (async/future (tape/log logger :info (str ":one " i)))
      (async/future(tape/log logger :warn (str ":two" i)))
      (async/future (tape/log logger :error (str ":tree" i))))
    @(async/promise)))

  ;; (let [logger (tape/example-system {:levels #{:info :error}})]
  ;;   (tape/log logger :info "lambda :one")
  ;;   (tape/log logger :warn "lambda :two")
  ;;   (tape/log logger :error "lambda :tree")
  ;;   @(async/promise))
