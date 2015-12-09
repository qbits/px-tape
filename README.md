# Tape

<img src="http://i.imgur.com/yNrbl1D.png" title="Hosted by imgur.com" align="right"/>

Simple composable logging library for pixie, provides the building
blocks to make something not too awful (hopefully).

The main idea is to provide
[components](https://github.com/qbits/component) for appenders,
loggers, layouts and let the user compose them how he likes in his own
logging systems/components. For instance, you can share the same
appender for all levels or not, have multiple appenders for X levels,
different layouts etc, etc. Every component is **very** simple. I can
imagine to provide default systems for common usages down the road and
also a way to generate/load systems from config as data (file, edn,
etc).

Work in progress.

<!-- ## Installation -->

<!-- With [dust](https://github.com/pixie-lang/dust), add the following to -->
<!-- your project.edn `:dependencies`: -->

```clojure
[qbits/tape "0.1.1-alpha"]
```

## Example


```clojure
(require
   '[qbits.tape :as tape]
   '[qbits.component :as component]
   '[qbits.tape.layout.default :as layout]
   '[qbits.tape.appender.console :as console]
   '[qbits.tape.appender.file :as file]
   '[qbits.tape.appender :as a]   )

;; Create a logging system constructor
;; with different loggers using shared or independent appenders/layouts

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

;; initialize with default log :levels
(def sys (example-system {:levels #{:info :error}}))

;; log stuff
(tape/warn (:loggerB sys) "two")
(tape/info (:loggerB sys) "two")
(tape/log (:loggerA sys) :info "one")
(tape/log (:loggerC sys) :error "three")

```

## License

Copyright © 2015 [Max Penet](https://twitter.com/mpenet)

Distributed under the Eclipse Public License
