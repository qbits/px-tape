# Logs stuff

Simple composable logging library for pixie, provides the building
blocks ([components](https://github.com/mpenet/component)) to make
something not too awful (hopefully).

The main idea is to provide
[components](https://github.com/mpenet/component) for appenders,
loggers, layouts and let the user compose them how he likes in his own
logging systems. For instance, you can share the same appender for all
levels or not, have multiple appenders for X levels, different layouts
etc, etc. Every component is **very** simple. I can imagine to provide
default systems for common usages down the road.

Work in progress.

## License

Copyright © 2015 [Max Penet](https://twitter.com/mpenet)

Distributed under the Eclipse Public License
