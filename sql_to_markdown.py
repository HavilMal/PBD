import re
import argparse

def to_markdown(text):
    markdown = ""

    it = iter(text)
    
    def n(iterator):
        try:
            t = next(iterator)
            return t
        except StopIteration:
            return "" 

    for line in it:
        title = ""
        comment = []
        sql = []
        # t = line.strip()
        t = line
        
        if t == "":
            continue 
        
        r = re.match(r"--(.+$)", t)
        if r:
            title = r.group(1)
            
        t = n(it)
        r = re.match(r"--(.+$)", t)
        while r:
            comment.append(r.group(1))
            t = n(it)
            r = re.match(r"--(.+$)", t)
        

        while not t.isspace() and t != "":
            sql.append(t);
            t = n(it)
            
        markdown += f'### {title}\n'
        
        for c in comment:
            markdown += c.strip() + " "
            
        if len(comment) > 0:
            markdown += '\n'
            
        markdown += '```sql\n'
        for s in sql:
            markdown += s
        markdown += "```\n\n"
        
    return markdown
            
            
parser = argparse.ArgumentParser( prog='sql to markdown')
parser.add_argument('filename') 
parser.add_argument('output') 
parser.add_argument('-a', action='store_true')
args = parser.parse_args()

with open(args.filename, "r") as text:
    markdown = to_markdown(text)
    
    mode = '+a' if args.a else '+w'
    
    with open(args.output, mode) as out:
        out.write(markdown)
        


    

    

    
    