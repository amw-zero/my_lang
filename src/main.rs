use pest::{self, Parser};
use std::collections::HashMap;

#[derive(pest_derive::Parser)]
#[grammar = "grammar.pest"]
struct LangParser;

#[derive(Debug)]
enum AstNode {
    InvalidNode,
    SchemaDef { name: Box<AstNode>, body: Box<AstNode> },
    SchemaBody {
        definitions: Vec<AstNode>,
    },
    Identifier(String),
    Type(Box<AstNode>),
    SchemaAttribute {
        name: Box<AstNode>,
        r#type: Box<AstNode>,
    },
    SchemaMethod {
        name: Box<AstNode>,
    }
}

fn identifier(pair: pest::iterators::Pair<Rule>) -> AstNode {
    return AstNode::Identifier(pair.as_str().into());
}

fn identifier_name(identifier: AstNode) -> String {
    if let AstNode::Identifier(name) = identifier {
        return name;
    }

    return "invalid parse".into();
}

fn r#type(pair: pest::iterators::Pair<Rule>) -> AstNode {
    let name = identifier(pair.into_inner().next().unwrap());
    return AstNode::Type(Box::new(name));
}

fn schema_method(pair: pest::iterators::Pair<Rule>) -> AstNode {
    let name = identifier(pair.into_inner().next().unwrap());

    return AstNode::SchemaMethod { name: Box::new(name) };
}

fn attribute(pair: pest::iterators::Pair<Rule>,) -> AstNode {
    let mut inner = pair.into_inner();
    let name = identifier(inner.next().unwrap());
    let r#type = r#type(inner.next().unwrap());

    return AstNode::SchemaAttribute{ name: Box::new(name), r#type: Box::new(r#type) }
}

fn parse(pair: pest::iterators::Pair<Rule>) -> AstNode {
    match pair.as_rule() {
        Rule::Schema => {
            let mut inner = pair.into_inner();
            let name = identifier(inner.next().unwrap());
            let body = parse(inner.next().unwrap());

            let schema = AstNode::SchemaDef { name: Box::new(name), body: Box::new(body) };
            
            return schema;
        },
        Rule::SchemaBody => {
            let inner = pair.into_inner();
            let definitions = inner.map(parse).collect();

            return AstNode::SchemaBody { definitions: definitions };
        },
        Rule::SchemaAttribute => attribute(pair),
        Rule::SchemaMethod => schema_method(pair),
        Rule::Identifier => AstNode::Identifier(pair.as_str().into()),
        _ => { 
            println!("Other");
            return AstNode::InvalidNode;
        }
    }
}

fn main() {
    let source = std::fs::read_to_string("./src/test.lang").expect("Gotta exist");
    let result = LangParser::parse(Rule::Program, &source);
//    let mut schemas: HashMap<String, AstNode> = HashMap::new();
    let mut statements: Vec<AstNode> = vec![];
    match result {
        Ok(pairs) => {
            for pair in pairs {
                statements.push(parse(pair))
            }
        },
        Err(e) => println!("Error {:?}", e)
    }

    println!("{:?}", statements)
}
