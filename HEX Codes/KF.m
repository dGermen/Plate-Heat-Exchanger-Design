classdef KF
    % Constants and formulas are determined in this class file
    
    properties (Constant)
        IPValues = struct("heatCapacity",[4217,4211,4198,4189,4184,4181,4179,4178,4178,4179,4180,4182,4184,4186,4188,4191,4195,4199,4203,4209,4214,4217,4220,4226,4232,4239,4256,4278,4302,4331],...
                          "density",[1000,1000,1000,1000,999,998,997.010000000000,995.020000000000,993.050000000000,991.080000000000,989.120000000000,987.170000000000,984.250000000000,982.320000000000,979.430000000000,976.560000000000,973.710000000000,970.870000000000,967.120000000000,963.390000000000,960.610000000000,957.850000000000,956.940000000000,953.290000000000,949.670000000000,945.180000000000,937.210000000000,928.510000000000,919.120000000000,909.920000000000],...
                          "viscosity",[0.00175000000000000,0.00175000000000000,0.00142200000000000,0.00122500000000000,0.00108000000000000,0.000959000000000000,0.000855000000000000,0.000769000000000000,0.000695000000000000,0.000631000000000000,0.000577000000000000,0.000528000000000000,0.000489000000000000,0.000453000000000000,0.000420000000000000,0.000389000000000000,0.000365000000000000,0.000343000000000000,0.000324000000000000,0.000306000000000000,0.000289000000000000,0.000279000000000000,0.000274000000000000,0.000260000000000000,0.000248000000000000,0.000237000000000000,0.000217000000000000,0.000200000000000000,0.000185000000000000,0.000173000000000000],...
                          "thermalConductivity",[0.569000000000000,0.574000000000000,0.582000000000000,0.590000000000000,0.598000000000000,0.606000000000000,0.613000000000000,0.620000000000000,0.628000000000000,0.634000000000000,0.640000000000000,0.645000000000000,0.650000000000000,0.656000000000000,0.660000000000000,0.664000000000000,0.668000000000000,0.671000000000000,0.674000000000000,0.677000000000000,0.679000000000000,0.680000000000000,0.681000000000000,0.683000000000000,0.685000000000000,0.686000000000000,0.688000000000000,0.688000000000000,0.688000000000000,0.685000000000000],...
                          "prandtlNumber",[12.9900000000000,12.2200000000000,10.2600000000000,8.81000000000000,7.56000000000000,6.62000000000000,5.83000000000000,5.20000000000000,4.62000000000000,4.16000000000000,3.77000000000000,3.42000000000000,3.15000000000000,2.88000000000000,2.66000000000000,2.45000000000000,2.29000000000000,2.14000000000000,2.02000000000000,1.91000000000000,1.80000000000000,1.76000000000000,1.70000000000000,1.61000000000000,1.53000000000000,1.47000000000000,1.34000000000000,1.24000000000000,1.16000000000000,1.09000000000000],...
                          "temperature",[273.150000000000,275,280,285,290,295,300,305,310,315,320,325,330,335,340,345,350,355,360,365,370,373.150000000000,375,380,385,390,400,410,420,430])
        stainlessSteel = struct("thermalConductivity",16.5);
        
        priceData = struct("CEPCI",struct("CEPCI2010",532.9,"CEPCI2020",607.5,"CEPCI2002",396,"CEPCI2020_2010",1.14,"CEPCI2020_2002",1.534090909)...
            ,"locationFactor",struct("USA",1,"Turkey",1.07,"Turkey_USA",1.07)...
            ,"electricityPrice",0.000000194...
            ,"Dollar2TL",7.38);
    end
    
    methods (Static)
        function value = waterValues(valueType, temperature)
            
            yValuesAll = KF.IPValues;
            temperatures = yValuesAll.temperature;
            
            switch valueType
                case {"heatCapacity", "hc","spesificHeat","sh","cp"}
                    yValues = yValuesAll.heatCapacity;
                case {"density", "d"}
                    yValues = yValuesAll.density;
                case {"viscosity", "v"}
                    yValues = yValuesAll.viscosity;
                case {"thermalConductivity", "tc"}
                    yValues = yValuesAll.thermalConductivity;
                case {"prandtlNumber", "pn"}
                    yValues = yValuesAll.prandtlNumber;
                case {"temperature", "t"}
                    yValues = yValuesAll.temperature;
            end
            
            value = interp1(temperatures, yValues, temperature);
        end
        
        function [price] = plateArea2Price2002(plateArea)
           price = 13.216 * plateArea + 610.67; 
        end
        
        
        function [tableR] = objectArray2Table(objArray)
            
            firstObj = objArray{1};
            objProperties = convertCharsToStrings( properties( firstObj ) );
            rowSize = length(objArray);
            % Add + 1 for indexing???
            columnSize = length(objProperties);
            resultMatrix = zeros([rowSize,columnSize],"double");
            
            for row = 1:rowSize
                obj = objArray{row};
                objValues = transpose(cellfun(@(name) obj.(name), objProperties));
                resultMatrix(row,:) = objValues;
            end
            
            tableR = array2table(resultMatrix);
            
            tableR.Properties.VariableNames = objProperties;
            tableR.Properties.RowNames = string(linspace(1,rowSize,rowSize));
        end
        
        function [dateTimeStr] = getDateTimeStrWOSpace()
            dt = datestr(datetime);
            dateTimeStr = regexprep(regexprep(dt, ' ', '-'),':','-');
        end
        
        function filteredTable = filterTable(...
                tableUnfiltered,variableName,wantedValue,rangePercentage)
            condition = @(value) wantedValue*(1-rangePercentage/100) >= value |...
                value >= wantedValue*(1+rangePercentage/100);
            values = tableUnfiltered.(variableName);
            
            logicalArray = arrayfun(condition,values);
            
            tableUnfiltered(logicalArray,:) = [];
            
            filteredTable = tableUnfiltered;
        end


    end
end

