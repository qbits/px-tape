(ns qbits.tape.appender.file
  (:require
   [qbits.tape.appender :refer :all]
   [qbits.tape.layout :refer [format]]
   [qbits.component :as component :refer [start stop]]
   [pixie.csp :as csp]
   [pixie.io :as io]
   [pixie.uv :as uv]))

(defn- open-write
  [filename]
  (assert (string? filename) "Filename must be a string")
  (io/->FileOutputStream (io/throw-on-error (io/fs_open filename
                                                        (bit-or uv/O_WRONLY uv/O_APPEND)
                                                        uv/S_IRWXU))
                         0
                         (uv/uv_buf_t)))

(defrecord FileAppender [;; locals
                         chan
                         file-output-stream
                         ;; opts
                         file
                         buffer-size
                         ;; deps
                         layout]
  component/Lifecycle
  (start [this]
    (let [fos (open-write file)
          ch (csp/chan buffer-size)]
      (csp/go
        (loop []
          (io/spit fos (str (format layout (csp/<! ch)) "\n"))
          (recur)))
      (-> this
          (assoc :chan ch)
          (assoc :file-output-stream fos))))
  (stop [this]
    (csp/close! chan)
    (dispose! file-output-stream)
    (-> this
        (assoc :chan nil)
        (assoc :file-output-stream nil)))

  IAppender
  (append! [this entry]
    (csp/put! chan entry)))

(def default-options
  {:buffer-size 100})

(defn new-file-appender
  ([] (new-file-appender default-options))
  ([opts]
   (map->FileAppender (merge default-options opts))))
