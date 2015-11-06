(ns qbits.tape.time
  (:require
   [pixie.uv :as uv]
   [pixie.ffi]
   [pixie.ffi-infer :as f]))

(f/with-config {:library "c"
                :cxx-flags ["-lc"]
                :includes ["time.h"]}
  (def time_t (pixie.ffi/c-struct :time_t 8 [[:val CInt 0]]))
  (f/defcfn time)
  (f/defcfn gmtime)
  (f/defcfn strftime)
  (f/defcfn localtime)
  ;; (f/defcstruct tm [:tm_sec
  ;;                   :tm_min
  ;;                   :tm_hour
  ;;                   :tm_mday
  ;;                   :tm_mon
  ;;                   :tm_year
  ;;                   :tm_wday
  ;;                   :tm_yday
  ;;                   :tm_isdst])
)

(defn now
  ([fmt]
   (let [buf (buffer 80)
         tt (time_t)
         _ (time tt)
         ti (localtime tt)]
     (->> (strftime buf 81 fmt ti)
          (set-buffer-count! buf))
     (transduce (map char) string-builder buf)))
  ([] (now "%Y-%m-%d %H:%M:%S")))
