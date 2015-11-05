(ns qbits.tape.logger
  (:require
   [pixie.uv :as uv]
   [qbits.component :as component :refer [start stop]]
   [qbits.tape.appender :as a]))

(defrecord Message [level ns timestamp message])

(defprotocol ILogger
  (log [this level entry]))

(defrecord Logger [;; locals
                   ;; level
                   ;; deps
                   appender
                   layout]
  component/Lifecycle
  (start [this] this)
  (stop [this] this)

  ILogger
  (log [this level message]
    (let [entry (->Message level
                           (name *ns*)
                           (uv/uv_hrtime)
                           message)]
      (a/append! appender entry))))

(defn new-logger
  ([] (new-logger {}))
  ([opts]
   (map->Logger opts)))
