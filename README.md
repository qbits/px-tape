# Logs stuff

<img src="http://i.imgur.com/yNrbl1D.png" title="Hosted by imgur.com" align="right"/>

Simple composable logging library for pixie, provides the building
blocks to make something not too awful (hopefully).

The main idea is to provide
[components](https://github.com/mpenet/component) for appenders,
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

<!-- ```clojure -->
<!-- [mpenet/tape "0.1.1-alpha"] -->
<!-- ``` -->

## License

Copyright © 2015 [Max Penet](https://twitter.com/mpenet)

Distributed under the Eclipse Public License
