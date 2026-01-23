# Unformatted Python for fixy demo - lots of style issues!
import json,sys,os
from typing import Dict,List,Optional

class   DataProcessor:
    """A class with various formatting issues."""

    def __init__(self,name:str,config:Dict):
        self.name=name
        self.config=config
        self.results:List[str]=[]

    def process(self,items:List[str])->List[str]:
        processed=[]
        for item in items:
            if item and len(item)>0:
                processed.append(item.strip().lower())
        return processed

    def validate(self,data:Optional[Dict]=None)->bool:
        if data is None:return False
        return "id" in data and "name" in data

def   format_output(results:List[str],prefix:str=">>>")->str:
    lines=[]
    for i,result in enumerate(results):
        lines.append(f"{prefix} {i+1}. {result}")
    return "\n".join(lines)

SMART_QUOTES_TEST = "This has "smart quotes" and 'apostrophes'"

# keep-sorted start
ITEMS = [
    "zebra",
    "apple",
    "mango",
    "banana",
]
# keep-sorted end

if __name__=="__main__":
    processor=DataProcessor("demo",{"verbose":True})
    data=["  HELLO  ","World  ","  Python"]
    results=processor.process(data)
    print(format_output(results))
