//
//  MyRssParser.swift
//  RssParserSample
//
//  Created by Petr Budík on 28.11.18.
//  Copyright © 2018 Petr Budík. All rights reserved.
//

import Foundation

struct RssItem {
	var title: String;
	var description: String;
	var pubDate: String;
}

class MyFeedParser: NSObject, XMLParserDelegate {
	private var rssItems: [RssItem]=[];
	private var currentElement = "";
	
	private var currentTitle = "" {
		didSet {
			currentTitle = currentTitle.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
		}
	}
	
	private var currentDescription = "" {
		didSet {
			currentDescription = currentDescription.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
		}
	}
	
	private var currentPubDate = ""{
		didSet {
			currentPubDate = currentPubDate.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
		}
	}
	
	private var parserCompletionHandler: (([RssItem]) -> Void)?
	
	func parseFeed(url: String, completionHandler: (([RssItem]) -> Void)?) {
		self.parserCompletionHandler = completionHandler;
		
		let request = URLRequest(url: URL(string: url)!);
		let urlSession = URLSession.shared;
		
		let task = urlSession.dataTask(with: request) { (data, response, error) in
			guard let data = data else{
				if let error = error {
					print(error.localizedDescription)
				}
				
				return
			}
			
			/// Parse XML data
			let parser = XMLParser(data: data);
			parser.delegate = self;
			parser.parse();
		}
		
		task.resume();
	}
	
	// MARK: XML parser delegate
	/**
	Called when opening tag was parsed.
	*/
	func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
		currentElement = elementName;
		if currentElement == "item" {
			currentTitle = "";
			currentDescription = "";
			currentDescription = "";
		}
	}
	/**
	Called when data inside a tag is parsed.
	*/
	func parser(_ parser: XMLParser, foundCharacters string: String) {
		switch currentElement {
		case "title": currentTitle += string;
		case "description": currentDescription += string;
		case "pubDate": currentPubDate += string;
		default: break;
		}
	}
	
	/**
	Called when leaving a tag.
	*/
	func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
		if elementName == "item" {
			let rssItem = RssItem(title: currentTitle, description: currentDescription, pubDate: currentPubDate)
			self.rssItems.append(rssItem);
		}
	}
	
	/**
	Called at the end of the document.
	*/
	func parserDidEndDocument(_ parser: XMLParser) {
		parserCompletionHandler?(rssItems);
	}
	
	/**
	Called when parsing error occures.
	*/
	func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
		print(parseError.localizedDescription)
	}
}
