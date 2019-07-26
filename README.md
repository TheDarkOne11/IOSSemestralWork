# RSS Feed reader for IOS
[![Build Status](https://travis-ci.com/budikpet/IOSSemestralWork.svg?branch=master)](https://travis-ci.com/budikpet/IOSSemestralWork)

My semestral project used for BI-IOS Winter 2018 and MI-IOS Summer 2020.

Simple RSS Feed reader somewhat similar to [my Android one](https://github.com/TheDarkOne11/AndroidSemestralWork). 

Uses Realm to persist data, AlamoFireRSSParser as RSSParser.

In comparison to the BI-IOS version, the MI-IOS version looks more or less the same. Most changes were internal.
It has these new features: 
- uses MVVM & Repository pattern and modular project
- uses ReactiveSwift and ReactiveCocoa
- uses Realm more appropriately. All models done much better now.
- uses protocol-based DI
- added Today app extension
- added basic Unit tests
- enabled automatic CI using Travis
- english and czech localization that uses a special library that enables us to get data from a Google Sheet
- uses Swiftgen library to generate enums of localization strings and assets
