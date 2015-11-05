(ns qbits.tape.appender.console
  (:require
   [qbits.tape.appender :refer :all]
   [qbits.tape.layout :refer [format]]
   [qbits.component :as component :refer [start stop]]
   [pixie.csp :as csp]
   [pixie.io :as io]
   [pixie.io.tty :as tty]
   [pixie.system :as sys]))

(defrecord ConsoleAppender [;; locals
                            chan
                            ;; opts
                            buffer-size
                            ;; deps
                            layout]
  component/Lifecycle
  (start [this]
    (let [ch (csp/chan buffer-size)]
      (csp/go
        (loop []
          (io/spit tty/stdout (str (format layout (csp/<! ch))
                                   "\n"))
          (recur)))
      (-> this (assoc :chan ch))))
  (stop [this]
    (csp/close! chan)
    (-> this
        (assoc :chan nil)))

  IAppender
  (append! [this entry]
    (csp/put! chan entry)))

(def default-options
  {:buffer-size 100})

(defn new-console-appender
  ([] (new-console-appender default-options))
  ([opts]
   (map->ConsoleAppender (merge default-options opts))))
