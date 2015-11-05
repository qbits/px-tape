(ns qbits.tape.layout.default
  (:require
   [qbits.tape.layout :refer :all]
   [pixie.string :as str]))

(def tab "\t")

(defrecord DefaultLayout []
  ILayout
  (format [this message]
    (str (-> message :level name str/upper-case) tab
         (:ns message) tab
         (:timestamp message) tab
         (:message message))))

(defn new-default-layout
  ([] (new-default-layout {}))
  ([opts] (map->DefaultLayout opts)))
