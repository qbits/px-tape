(ns qbits.tape
  (:require
   [qbits.component :as component :refer [start stop]]
   [qbits.tape.layout.default :as layout]
   [qbits.tape.appender.console :as console]
   [pixie.uv :as uv]
   [qbits.tape.appender :as a]
   [pixie.ffi-infer :as f]))

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
(def default-opts {:levels #{:info :warn :errors :fatal}})

(defrecord Message [level ns timestamp message])

;; (f/with-config {:library "c"
;;                 :cxx-flags ["-lc"]
;;                 :includes ["time.h"]
;;                 }
;;   (def time_t (pixie.ffi/c-struct :time_t 8 [[:val CInt 0 ]]))
;;   (f/defcfn time)
;;   (f/defcstruct tm [:tm_sec
;;                     :tm_min
;;                     :tm_hour
;;                     :tm_mday
;;                     :tm_mon
;;                     :tm_year
;;                     :tm_wday
;;                     :tm_yday
;;                     :tm_isdst])
;;   (f/defcfn gmtime)
;;   (f/defcfn localtime))

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
      (let [ts (uv/uv_hrtime)
            ;; t (timeval)
            ;; _ (gettimeofday t (buffer 0))
            ;; _ (prn t)
            entry (->Message level
                             (name *ns*)
                             ts
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
         :layoutA default-layout
         :loggerA (component/using (new-logger {:levels [:info :error]})
                                   {:appender :appenderA}))
        component/start)))
