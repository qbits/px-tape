(ns qbits.tape
  (:require
   [qbits.component :as component :refer [start stop]]
   [qbits.tape.layout.default :as layout]
   [qbits.tape.appender.console :as console]
   [qbits.tape.appender.file :as file]
   [qbits.aeon :as time]
   [pixie.uv :as uv]
   [qbits.tape.appender :as a]))

;; 1 logger per active level+appender, at discretion of the user to
;; share appenders/loggers/layouts systems should be generated from
;; config (file or entry point options somewhere), provide a few
;; templates also there is not log level chain, if you want both error
;; and info you need to specify both

;; FIXME/TODO:
;; * options everywhere, make what can be static static (ex *ns*)
;; * provide macro versions ? (depends on what jit does with noop calls)
;; * do not depend on pixie.tty
;; * date formatting (via ffi)
;; * write more appenders/layouts
;; * bench

(def levels [:trace :debug :info :warn :error :fatal])
(def default-layout (layout/new-default-layout))
(def default-appender (console/new-console-appender))
(def default-opts {:levels #{:info :warn :errors :fatal}
                   :time-fn #(time/format (time/new-datetime)
                                          "%Y-%m-%d %H:%M:%S")})

(defrecord Message [level ns timestamp message])

(defprotocol ILogger
  (log? [this level])
  (log [this level entry])
  (debug [this entry])
  (trace [this entry])
  (info [this entry])
  (warn [this entry])
  (error [this entry])
  (fatal [this entry]))

(defrecord Logger [levels
                   time-fn ;; get rid of this once we have more adv time utils
                   ;; deps
                   appender
                   layout]
  component/Lifecycle
  (start [this]
    (println levels)
    (-> this (assoc :levels (set levels))))
  (stop [this] this)

  ILogger
  (log [this level message]
    (when (log? this level)
      (let [entry (->Message level
                             (name *ns*)
                             (time-fn)
                             message)]
        (a/append! appender entry))))

  (log? [this level]
    (contains? levels level))

  (debug [this message]
    (log this :debug message))

  (trace [this message]
    (log this :trace message))

  (info [this message]
    (log this :info message))

  (warn [this message]
    (log this :warn message))

  (error [this message]
    (log this :error message))

  (fatal [this message]
    (log this :fatal message)))

(defn new-logger
  ([] (new-logger {}))
  ([opts]
   (map->Logger opts)))


;;
;; testing the whole thing
;;

(defn example-system [opts]
  (let [opts (merge default-opts opts)]
    (-> (component/system-map
         :appenderA (component/using default-appender
                                     {:layout :layoutA})
         :appenderB (component/using (file/new-file-appender {:file "./test.log"})
                                     {:layout :layoutA})

         :appenderC (component/using (file/new-rolling-file-appender {:file "./testr.log"})
                                     {:layout :layoutA})
         :layoutA default-layout
         :loggerA (component/using (new-logger default-opts)
                                   {:appender :appenderA})
         :loggerB (component/using (new-logger default-opts)
                                   {:appender :appenderB})

         :loggerB (component/using (new-logger default-opts)
                                   {:appender :appenderB})

         :loggerC (component/using (new-logger default-opts)
                                   {:appender :appenderC}))
        component/start)))
