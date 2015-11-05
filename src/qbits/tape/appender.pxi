(ns qbits.tape.appender)

(defprotocol IAppender
  (append! [this entry]))
