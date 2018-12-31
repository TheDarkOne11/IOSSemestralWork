//
//  RSSItemVC.swift
//  IOSSemestralWork
//
//  Created by Petr Budík on 30/12/2018.
//  Copyright © 2018 Petr Budík. All rights reserved.
//

import UIKit
import WebKit

class RSSItemVC: UIViewController {
    var selectedRssItem: MyRSSItem?

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    func loadItem() {
        let testRssItem = MyRSSItem(with: nil)
        testRssItem.title = "Prezident Zeman plánuje odpočinkový rok. Jen krátké cesty, ale znovu Čína"
        testRssItem.author = "Unknown"
        testRssItem.link = "https://zpravy.idnes.cz/zeman-hrad-odpocinek-zahranicni-cesty-dxg-/domaci.aspx?c=A181218_104225_domaci_jabe#utm_source=rss&utm_medium=feed&utm_campaign=zpravodaj&utm_content=main"
        testRssItem.itemDescription = """
        Od listopadové návštěvy v Izraeli odpočívá, na konec letošního roku si naordinoval i s hradním mluvčím Jiřím Ovčáčkem třítýdenní dovolenou. A odpočinkový režim bude mít prezident Miloš Zeman i příští rok. Zatím má v plánu pět zahraničních cest. Vyrazí opět na Slovensko a do Číny.
        
        <ul><b>Další články k tématu:</b><li><a href=\"https://zpravy.idnes.cz/videa-tydne-zeman-parodie-orsava-teroristicky-utok-strasburk-d1-kolaps-pocasi-soukup-urazka-barrando-ibd-/domaci.aspx?c=A181216_154745_domaci_rejs#utm_source=rss&utm_medium=feed&utm_campaign=zpravodaj&utm_content=related\">VIDEA TÝDNE: Zeman v parodii, útok ve Štrasburku a kolaps na dálnici D1</a></li><li><a href=\"https://kultura.zpravy.idnes.cz/harry-potter-zeman-parodie-video-michal-orsava-fln-/filmvideo.aspx?c=A181214_170737_filmvideo_kiz#utm_source=rss&utm_medium=feed&utm_campaign=zpravodaj&utm_content=related\">VIDEO: Takto se točila parodie na Harryho Pottera se Zemanem a Babišem</a></li><li><a href=\"https://zpravy.idnes.cz/eu-rusko-sankce-diplomacie-d0k-/zahranicni.aspx?c=A181213_185215_zahranicni_luka#utm_source=rss&utm_medium=feed&utm_campaign=zpravodaj&utm_content=related\">Zemanovi navzdory. EU znovu prodloužila hospodářské sankce proti Rusku</a></li><li><a href=\"https://zpravy.idnes.cz/zeman-vecere-adventni-lany-zamek-vlada-premier-ministri-babis-pu7-/domaci.aspx?c=A181210_183953_domaci_pmk#utm_source=rss&utm_medium=feed&utm_campaign=zpravodaj&utm_content=related\">Ministři večeřeli u prezidenta Zemana, adventní setkání se má stát tradicí</a></li></ul>
        """
        selectedRssItem = testRssItem
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadItem()

        let description = selectedRssItem!.itemDescription
        
        let testStr = "Lets go now or never. <p> <b>hello</b>, <i>world</i>"
        titleLabel.text = selectedRssItem!.title
        descriptionLabel.setHTMLFromString(htmlText: description)
        descriptionLabel.sizeToFit()
    }
    
    // MARK: Navigation
    
    @IBAction func goToWebButtonPressed(_ sender: UIBarButtonItem) {
        guard let url = URL(string: "https://www.idnes.cz") else { return }
        UIApplication.shared.open(url)
    }
}

extension UILabel {
    func setHTMLFromString(htmlText: String, family: String? = "-apple-system") {
        let modifiedFont = String(format:"<span style=\"font-family: \(family!), 'HelveticaNeue'; font-size: \(self.font!.pointSize)\">%@</span>", htmlText)
        
        
        //process collection values
        let attrStr = try! NSAttributedString(
            data: modifiedFont.data(using: .unicode, allowLossyConversion: true)!,
            options: [.documentType: NSAttributedString.DocumentType.html,
                      .characterEncoding: String.Encoding.utf8.rawValue],
            documentAttributes: nil)
        
        
        self.attributedText = attrStr
    }
}
