//
//  BCPubmedParser.h
//  Caravan
//
//  Created by Tom Houpt on 15/3/17.
//  Copyright (c) 2015 Tom Houpt. All rights reserved.
//

/** Overview
 
When a PMID number is pasted into a Caravan text file, or a PMID url is dragged from a webbroswer, the citation is first inserted with the identifer @"PMID: nnnnnnnn". (A PMID number is recognized by the string @"http://www.ncbi.nlm.nih.gov/pubmed/nnnnnnnn, or by @"PMID: nnnnnnnn".)Then, Caravan retrieves the pubmed citation information by posting a query using the PMID to the pubmed server, to retrieve the Pubmed XML entry. The resulting XML is in "PubmedArticle" format, which is parsed into a dictionary and then used to populate the Caravan reference citation fields. Once a PMID citation has been retreived from the pubmed server, the inline references are updated with the universal citekey.

Not all the fields within the Pubmed XML citation are used to populate the Caravan reference, because the pubmed citation contains additional metadata which is not needed for bibliographic information (e.g. chemical, pubmed history, medline citations )



Sources:

Citation information is retrieved in Pubmed XML format using the query:
 
 ```
 http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&id=%ld&retmode=xml
 ```
 
where %ld is replaced with the pasted PMID number.
(Note that the citation is not retrieved in "eSummary" or "medline" or "text (pubmed entry)" formats. See see http://www.ncbi.nlm.nih.gov/books/NBK25499/ for valid ranges of retmode and rettype.)
 
 The XML elements are described at:
 
 Overview: http://www.nlm.nih.gov/bsd/licensee/data_elements_doc.html
 Alphabetical list: http://www.nlm.nih.gov/bsd/licensee/elements_alphabetical.html
 Descriptions: http://www.nlm.nih.gov/bsd/licensee/elements_descriptions.html
 
 the formal DTD description is at:
 http://www.nlm.nih.gov/databases/dtd/nlmmedlinecitationset_150101.dtd from http://www.nlm.nih.gov/databases/dtd/index.html
 
 
 
##PMIDParser xmlDictionary keys
###Element keys
 @"Abstract",
 @"AffiliationInfo",
 @"Article",
 @"Author",
 @"Chemical",
 @"CommentsCorrections",
 @"DateCompleted",
 @"DateCreated",
 @"DateRevised",
 @"Investigator",
 @"Journal",
 @"JournalIssue",
 @"MedlineCitation",
 @"OtherAbstract",
 @"Pagination",
 @"PersonalNameSubject",
 @"PubDate",
 @"History",
 @"MedlineJournalInfo",
 @"PubmedArticle",
 @"PubmedArticleSet",
 @"PubmedData",
 @"PubMedPubDate"
 
###Array Element Keys
 @"AccessionNumberList",
 @"AuthorList",
 @"ChemicalList",
 @"CollectiveName",
 @"DataBankList",
 @"GeneSymbolList",
 @"GrantList",
 @"InvestigatorList",
 @"KeywordList",
 @"MeshHeadingList",
 @"PersonalNameSubjectList",
 @"PublicationTypeList",
 @"SupplMeshList",
 @"ArticleIdList",
 @"CommentsCorrectionsList"
 
##Fields used to populate Caravan citation
 
 PubmedArticleSet/PubmedArticle/MedlineCitation/Article/Journal/ISSN
 PubmedArticleSet/PubmedArticle/MedlineCitation/Article/Journal/JournalIssue/Volume
 PubmedArticleSet/PubmedArticle/MedlineCitation/Article/Journal/JournalIssue/Issue
 PubmedArticleSet/PubmedArticle/MedlineCitation/Article/Journal/JournalIssue/PubDate/Year
 PubmedArticleSet/PubmedArticle/MedlineCitation/Article/Journal/Title
 PubmedArticleSet/PubmedArticle/MedlineCitation/Article/Journal/ISOAbbreviation
 PubmedArticleSet/PubmedArticle/MedlineCitation/Article/ArticleTitle
 PubmedArticleSet/PubmedArticle/MedlineCitation/Article/Pagination/MedlinePgn
 PubmedArticleSet/PubmedArticle/MedlineCitation/Article/ELocationID
 PubmedArticleSet/PubmedArticle/MedlineCitation/Article/Abstract/AbstractText
 PubmedArticleSet/PubmedArticle/MedlineCitation/Article/AuthorList
 PubmedArticleSet/PubmedArticle/MedlineCitation/KeywordList
 PubmedArticleSet/PubmedArticle/PubmedData/ArticleIdList
 
 ##Outline of PubMed XML file
 For brevity, closing tags have been mostly omitted.
 A "+" symbol after a tag indicates an  element within an array that may be repeated one or man times.
 
```
<PubmedArticleSet>
	<PubmedArticle>
		<MedlineCitation>
			<PMID>
			<DateCreated>
				<Year>
				<Month>
				<Day>
			<DateCompleted>
				<Year>
				<Month>
				<Day>
			<DateRevised>
				<Year>
				<Month>
				<Day>
			<Article>
				<Journal>
					<ISSN>
					<JournalIssue>
						<Volume>
						<Issue>
						<PubDate>
							<Year>
							<Month>
							<Day>
					<Title>
					<ISOAbbreviation>
				<ArticleTitle>
				<Pagination>
					<MedlinePgn>
				<ELocationID>
				<Abstract>
					<AbstractText>
					<CopyrightInformation>
				<AuthorList>
					<Author>+
						<LastName>
						<ForeName>
						<Suffix>
						<Initials>
						<AffiliationInfo>
							<Affiliation>
				<Language>
				<GrantList>
					<Grant>+
						<GrantID>
						<Acronym>
						<Agency>
						<Country>
				<PublicationTypeList>
					<PublicationType>+
				<ArticleDate>
					<Year>
					<Month>
					<Day>
			</Article>
			<MedlineJournalInfo>
				<Country>
				<MedlineTA>
				<NlmUniqueID>
				<ISSNLinking>
			<ChemicalList>
				<Chemical>+
					<RegistryNumber>
					<NameOfSubstance>
			<CitationSubset>
			<CommentsCorrectionsList>
				<CommentsCorrections RefType="Cites">+
					<RefSource>
					<PMID>
			<MeshHeadingList>
				<MeshHeading>+
					<DescriptorName>
					<QualifierName>
			<OtherID>
			<KeywordList>
				<Keyword>+
		</MedlineCitation>
		<PubmedData>
			<History>
				<PubMedPubDate>+
					<Year>
					<Month>
					<Day>
			<PublicationStatus>
			<ArticleIdList>
				<ArticleId>+
		</PubmedData>
	</PubmedArticle>
</PubmedArticleSet>
```
 
 
 
*/
#import <Foundation/Foundation.h>
#import "BCXMLDocumentParser.h"

#define kBCPubmedXMLRetrievedNotification @"BCPubmedXMLRetrievedNotification"
#define kBCPubmedParserCompletionNotification @"BCPubmedParserCompletionNotification"


@interface BCPubmedParser : BCXMLDocumentParser

@property NSInteger pmid;

/** given a pubmed id, the BCPubMedParser will query eutils.ncbi.nlm.nih.gov to retrieve the xml data, 
   then parse the xml into a dictionary containing citation fields
   
   kBCPubmedXMLRetrievedNotification is posted when the xml has been retrieved from nih.gov
   kBCPubmedParserCompletionNotification is posted when the xml has been parsed


*/
-(id)initWithPMID:(NSInteger)p;

@end
