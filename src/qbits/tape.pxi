(ns qbits.tape
  (:require
   [qbits.component :as component]
   [qbits.tape.layout.default :as layout]
   [qbits.tape.appender.console :as console]
   [qbits.tape.logger :as l]))

;; 1 logger per active level+appender, at discretion of the user to
;; share appenders/loggers/layouts systems should be generated from
;; config (file or entry point options somewhere), provide a few
;; templates also there is not log level chain, if you want both error
;; and info you need to specify both

;; FIXME/TODO:
;; * options everywhere, make what can be static static (ex *ns*)
;; * provide macro versions ? (depends on what jit does with noop calls)
;; * still not happy with project layout (might shuffle things)
;; * do not depend on pixie.tty
;; * date formatting (via ffi)
;; * write more appenders/layouts
;; * bench

(def levels [:trace :debug :info :warn :error :fatal])
(def default-layout (layout/new-default-layout))
(def default-appender (console/new-console-appender))

(def default-opts {:levels #{:info :warn :errors :fatal}})

(defn example-system [opts]
  (let [opts (merge default-opts opts)]
    (-> (component/system-map
         :options opts
         :appenderA (component/using l/default-appender
                                     {:layout :layoutA})
         :layoutA l/default-layout
         :logger (component/using (l/new-logger)
                                  {:appender :appenderA}))
        component/start)))

(defn log [sys level message]
  (when (-> sys :options :levels (contains? level))
    (l/log (:logger sys) level message)))

(defn debug [sys message]
  (log sys :debug message))

(defn trace [sys message]
  (log sys :trace message))

(defn info [sys message]
  (log sys :info message))

(defn warn [sys message]
  (log sys :warn message))

(defn error [sys message]
  (log sys :error message))

(defn fatal [sys message]
  (log sys :fatal message))
