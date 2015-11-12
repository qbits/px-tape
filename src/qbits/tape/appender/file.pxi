(ns qbits.tape.appender.file
  (:require
   [qbits.tape.appender :refer :all]
   [qbits.tape.layout :refer [format]]
   [qbits.aeon :as time]
   [qbits.component :as component :refer [start stop]]
   [pixie.csp :as csp]
   [pixie.io :as io]
   [pixie.fs :as fs]
   [pixie.uv :as uv]))


;; utils
(defn- open-write
  [filename]
  (assert (string? filename) "Filename must be a string")
  (io/->FileOutputStream (io/throw-on-error (io/fs_open filename
                                                        (bit-or uv/O_WRONLY (bit-or uv/O_CREAT uv/O_APPEND))
                                                        uv/S_IRWXU))
                         0
                         (uv/uv_buf_t)))

(def libc (ffi-library pixie.platform/lib-c-name))
(def strlen (ffi-fn libc "strlen" [CCharP] CInt))

(uv/defuvfsfn fs-rename pixie.uv/uv_fs_rename [source dest] :result)

;;


(defrecord FileAppender [;; locals
                         chan
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
          (if-let [msg (csp/<! ch)]
            (do
              (io/spit fos (str (format layout msg) "\n"))
              (recur))
            (dispose! fos))))
      (-> this
          (assoc :chan ch))))
  (stop [this]
    (csp/close! chan)
    (-> this
        (assoc :chan nil)))

  IAppender
  (append! [this entry]
    (csp/put! chan entry)))

;;

(def default-options
  {:buffer-size 100})

(defn new-file-appender
  ([] (new-file-appender default-options))
  ([opts]
   (map->FileAppender (merge default-options opts))))

;; Rolling file appender

(defrecord RollingFileAppender [;; locals
                                chan
                                ;; opts
                                file
                                max-file-size
                                buffer-size
                                ;; deps
                                layout]
  component/Lifecycle
  (start [this]
    (let [ch (csp/chan buffer-size)]
      (csp/go
        (loop [fos (open-write file)
               fsize (fs/size (fs/file file))]
          (if-let [msg (csp/<! ch)]
            (let [s (str (format layout msg) "\n")
                  mlen (strlen s)]
              (if (>= (+ fsize mlen) max-file-size)
                (do
                  (dispose! fos)
                  (fs-rename file (str file "." (uv/uv_hrtime)))
                  (let [fos (open-write file)]
                    (io/spit fos s)
                    (recur fos mlen)))
                (do
                  (io/spit fos s)
                  (recur fos (+ fsize mlen)))))
            (dispose! fos))))
      (assoc this :chan ch)))
  (stop [this]
    (csp/close! chan)
    (assoc this :chan nil))

  IAppender
  (append! [this entry]
    (csp/put! chan entry)))

(defn new-rolling-file-appender
  ([] (new-rolling-file-appender nil))
  ([opts]
   (map->RollingFileAppender
    (merge default-options
           {:max-file-size (* 5 1024 1024)}
           opts))))
