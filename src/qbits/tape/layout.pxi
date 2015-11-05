(ns qbits.tape.layout)

(defprotocol ILayout
  (format [this entry]))
