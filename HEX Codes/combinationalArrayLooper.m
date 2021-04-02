function resultArrayOut = combinationalArrayLooper(arrays, theFunction)

persistent loopTracker;
if isempty(loopTracker)
   loopTracker = 0; 
end

persistent resultArray;
if isempty(resultArray)
    resultArray = {};
end

persistent functionInputRelay;
if isempty(functionInputRelay)
    functionInputRelay = {};
end

persistent arraysPersistent;
if isempty(arraysPersistent)
    arraysPersistent = arrays;
    arraysPersistent{end + 1} = [];
end

persistent functionPersistent;
if isempty(functionPersistent)
    functionPersistent = theFunction;
end


loopTracker = loopTracker + 1;

if length(arraysPersistent) == loopTracker
    resultArray{end + 1} = functionPersistent(functionInputRelay);
end

for currentArrayIndex = 1:length(arraysPersistent{loopTracker})
    functionInputRelay{loopTracker} = arraysPersistent{loopTracker}(currentArrayIndex);
    combinationalArrayLooper();
end

loopTracker = loopTracker - 1;

if loopTracker == 0
   resultArrayOut = resultArray;
   resultArray = {};
   functionInputRelay = {};
   arraysPersistent = {};
   functionPersistent = {};
end



end