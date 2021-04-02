classdef plateHEX < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    %% Initial Properties
    properties
        flowRateCold % kg/s
        flowRateHot % kg/s
        TColdIn % K
        TColdOut % K
        THotIn % K
        THotOut % K
        
        % Plate properties
        NPlate 
        plateGap
        plateThickness
        plateArea
        plateRatio
        diameterPort
        enlargementFactor
        NPass
        chevronAngle
        foilingFactorCold
        foilingFactorHot
        
        lifeTime
        efficiencyCold
        efficiencyHot
    end
    %% Calculated Properties
    properties
        heatDuty % j/s - W
        TAvgCold
        TAvgHot
        TDifferenceCold
        TDifferenceHot
        LMTD % Log mean temperature
        
        NEPlate
        compressPlateHeadLength
        platePitch
        oneChannelFlowArea
        plateWidth % Total
        plateLength % Under ports
        plateLengthFromPortCenter
        plateAreaTotal
        plateAreaEffectiveTotal
        plateAreaEffective
        channelHydraulicDiameter
        NChannelsPerPass
        
        flowColdPC % per Channel
        flowHotPC % per Channel
        massVelocityColdPC
        massVelocityHotPC
        visocityCold
        visocityHot
        reynoldsColdPC
        reynoldsHotPC
        nusseltNumberCold
        nusseltNumberHot
        frictionFactorCold
        frictionFactorHot
        heatTransferCoefCold
        heatTransferCoefHot
        foilingFactor
        overallHeatTransferCoef
        overallHeatTransferCoefWithFoiling
        cleanlinessFactor
        heatDutyCalculated
        heatDutyCalculatedWithFoiling
%         safetyFactor      
        
        pressureLossChannelCold
        pressureLossChannelHot
        portMassVelocityCold
        portMassVelocityHot
        pressureLossPortCold
        pressureLossPortHot
        pressureLossTotalCold
        pressureLossTotalHot
        
        specificWorkCold
        specificWorkHot
        workCold
        workHot
        projectLifePumpingCostCold
        projectLifePumpingCostHot
        projectLifePumpingCost
        hexCost
        totalCost
        
        
        
        
    end
    %% Construtor, calculator functions
    methods
        function self = plateHEX2(flowRateCold,flowRateHot,...
                TColdIn,TColdOut,THotIn,THotOut,...
                NPlate,plateGap,plateThickness,plateArea,plateRatio,...
                diameterPort,enlargementFactor, NPass, chevronAngle, foilingFactorCold, foilingFactorHot,...
                lifeTime,efficiencyCold,efficiencyHot)
            
            self.flowRateCold = flowRateCold;
            self.flowRateHot = flowRateHot;
            self.TColdIn = TColdIn;
            self.TColdOut = TColdOut;
            self.THotIn = THotIn;
            self.THotOut = THotOut;
            
            self.NPlate = NPlate;
            self.plateGap = plateGap/1000;
            self.plateThickness = plateThickness/1000;
            self.plateArea = plateArea;
            self.plateRatio = plateRatio;
            self.diameterPort = diameterPort/100;
            self.enlargementFactor = enlargementFactor;
            self.NPass = NPass;
            self.chevronAngle = chevronAngle;
            self.foilingFactorCold = foilingFactorCold;
            self.foilingFactorHot = foilingFactorHot;
            
            self.lifeTime = lifeTime * 365 * 24 * 60 * 60;
            self.efficiencyCold = efficiencyCold/100;
            self.efficiencyHot = efficiencyHot/100;
            
            self.calculator();
        end
        
        function self = plateHEX(theArray)
            
            self.flowRateCold = theArray{1};
            self.flowRateHot = theArray{2};
            self.TColdIn = theArray{3};
            self.TColdOut = theArray{4};
            self.THotIn = theArray{5};
            self.THotOut = theArray{6};
            
            self.NPlate = theArray{7};
            self.plateGap = theArray{8}/1000;
            self.plateThickness = theArray{9}/1000;
            self.plateArea = theArray{10};
            self.plateRatio = theArray{11};
            self.diameterPort = theArray{12}/100;
            self.enlargementFactor = theArray{13};
            self.NPass = theArray{14};
            self.chevronAngle = theArray{15};
            self.foilingFactorCold = theArray{16};
            self.foilingFactorHot = theArray{17};
            
            self.lifeTime = theArray{18} * 365 * 24 * 60 * 60;
            self.efficiencyCold = theArray{19}/100;
            self.efficiencyHot = theArray{20}/100;
            
            self.calculator();
        end
        function calculator(self)
            self.TemperatureCalculations();
            self.HeatDuty();
            self.physicalPlateCalculations();
            self.flowRelatedCalculation();
            self.pressureLossCalculation();
            self.costCalculation();
        end
    end
    %%
    methods 
        function TemperatureCalculations(self)
            self.TDifferenceCold = abs(self.TColdOut - self.TColdIn);
            self.TDifferenceHot = abs(self.THotOut - self.THotIn);
            
            self.TAvgCold = (self.TColdOut + self.TColdIn) / 2;
            self.TAvgHot = (self.THotOut + self.THotIn) / 2;
            
            deltaT1 = self.THotIn - self.TColdOut;
            deltaT2 = self.THotOut - self.TColdIn;
            self.LMTD = (deltaT2 - deltaT1) / log(deltaT2 / deltaT1);
        end
        function HeatDuty(self)
            self.heatDuty = self.flowRateCold * self.TDifferenceCold * KF.waterValues("cp",self.TAvgCold); 
        end
        function physicalPlateCalculations(self)
            
            self.NEPlate = self.NPlate - 2;
            
            self.compressPlateHeadLength = self.NPlate * ( self.plateGap + self.plateThickness);
            
            self.platePitch = self.plateGap + self.plateThickness;
            
            % Plate with length and width calculation
            self.plateWidth = sqrt(self.plateArea / self.plateRatio);
            self.plateLength = self.plateWidth * self.plateRatio;
            
            self.oneChannelFlowArea = self.plateGap * self.plateWidth;
            
            self.plateLengthFromPortCenter = self.plateLength + self.diameterPort;
            
            self.plateAreaTotal = self.plateArea * self.NEPlate;
            
            %%%%
            % Calculate enlargement maybe???????
            %%%%
            self.plateAreaEffectiveTotal = self.plateAreaTotal * self.enlargementFactor;
            
            self.plateAreaEffective = self.plateAreaEffectiveTotal / self.NEPlate;
            
            self.channelHydraulicDiameter = 2 * self.plateGap / self.enlargementFactor;
            
            self.NChannelsPerPass = (self.NPlate - 1)/(2 * self.NPass);
                 
        end
        function flowRelatedCalculation(self)
            self.flowColdPC = self.flowRateCold / self.NChannelsPerPass;
            self.flowHotPC = self.flowRateHot / self.NChannelsPerPass;
            
            self.massVelocityColdPC = self.flowColdPC / self.oneChannelFlowArea;
            self.massVelocityHotPC = self.flowHotPC / self.oneChannelFlowArea;
            
            self.visocityCold = KF.waterValues("v",self.TAvgCold);
            self.visocityHot = KF.waterValues("v",self.TAvgHot);
            
            self.reynoldsColdPC = self.massVelocityColdPC * self.channelHydraulicDiameter / self.visocityCold;
            self.reynoldsHotPC = self.massVelocityHotPC * self.channelHydraulicDiameter / self.visocityHot;
            
            self.nusseltNumberFrictionFactorCalculation();
            
            self.heatTransferCoefCold = self.nusseltNumberCold * KF.waterValues("tc",self.TAvgCold) / self.channelHydraulicDiameter;
            self.heatTransferCoefHot = self.nusseltNumberHot * KF.waterValues("tc",self.TAvgHot) / self.channelHydraulicDiameter;
            
            % Add material selection maybe?
            self.foilingFactor = self.foilingFactorCold + self.foilingFactorHot;
            
            self.overallHeatTransferCoef = (1 / self.heatTransferCoefCold + ...
                1 / self.heatTransferCoefHot + self.plateThickness / KF.stainlessSteel.thermalConductivity)^-1;
            self.overallHeatTransferCoefWithFoiling = (1 / self.overallHeatTransferCoef + self.foilingFactor)^-1;
            
            self.cleanlinessFactor = self.overallHeatTransferCoefWithFoiling...
                / self.overallHeatTransferCoef;
            
            self.heatDutyCalculated = self.overallHeatTransferCoef * self.plateAreaEffectiveTotal * self.LMTD;
            self.heatDutyCalculatedWithFoiling = self.overallHeatTransferCoefWithFoiling * self.plateAreaEffectiveTotal * self.LMTD;
            
%             self.safetyFactor = self.heatDutyCalculatedWithFoiling...
%                 /self.heatDutyCalculated;
            
            
        end
        function pressureLossCalculation(self)
            
            % Losses in channels
            f = self.frictionFactorCold;
            g = self.massVelocityColdPC;
            d = KF.waterValues("d",self.TAvgCold);
            
            self.pressureLossChannelCold = 4 * f * ...
                self.plateLengthFromPortCenter * self.NPass / self.channelHydraulicDiameter ...
                * g^2 / (2 * d);
            
            f = self.frictionFactorHot;
            g = self.massVelocityHotPC;
            d = KF.waterValues("d",self.TAvgHot);
            
            self.pressureLossChannelHot = 4 * f * ...
                self.plateLengthFromPortCenter * self.NPass / self.channelHydraulicDiameter ...
                * g^2 / (2 * d);
            
            % Losses in ports
            self.portMassVelocityCold = self.flowRateCold / (pi * (self.diameterPort)^2 / 4);
            self.portMassVelocityHot = self.flowRateHot / (pi * (self.diameterPort)^2 / 4);
            
            self.pressureLossPortCold  = 1.4 * self.NPass * ...
                self.portMassVelocityCold^2 / (2 * KF.waterValues("d",self.TAvgCold));
            self.pressureLossPortHot  = 1.4 * self.NPass * ...
                self.portMassVelocityHot^2 / (2 * KF.waterValues("d",self.TAvgHot));
            
            % Losses total
            self.pressureLossTotalCold = self.pressureLossChannelCold + self.pressureLossPortCold;
            self.pressureLossTotalHot = self.pressureLossChannelHot + self.pressureLossPortHot;
            
        end
        function costCalculation(self)
            % Operating Cost
            self.specificWorkCold =  self.pressureLossTotalCold / ...
                KF.waterValues("d",self.TAvgCold) / self.efficiencyCold;
            self.specificWorkHot =  self.pressureLossTotalHot / ...
                KF.waterValues("d",self.TAvgHot) / self.efficiencyHot;
            
            self.workCold = self.specificWorkCold * self.flowRateCold;
            self.workHot = self.specificWorkHot * self.flowRateHot;
            
            self.projectLifePumpingCostCold = self.workCold * self.lifeTime * KF.priceData.electricityPrice;
            self.projectLifePumpingCostHot = self.workHot * self.lifeTime * KF.priceData.electricityPrice;
            
            self.projectLifePumpingCost = self.projectLifePumpingCostCold...
                + self.projectLifePumpingCostHot;
            
            % Fixed Cost
%             a = 1600;
%             b = 210;
%             n = 0.95;
% 
%             purchasePrice2010USA = a + b * (self.plateAreaTotal)^n;

            purchasePrice2002USA = KF.plateArea2Price2002(self.plateAreaTotal);
            purchasePrice2020USA = purchasePrice2002USA * KF.priceData.CEPCI.CEPCI2020_2002;
            purchasePrice2020Turkey = purchasePrice2020USA * KF.priceData.locationFactor.Turkey_USA;
            purchasePrice2020TurkeyTL = purchasePrice2020Turkey * KF.priceData.Dollar2TL;
           
            self.hexCost = purchasePrice2020TurkeyTL;
            
            % Total Cost
            self.totalCost = self.hexCost + self.projectLifePumpingCost;
        end
        function nusseltNumberFrictionFactorCalculation(self)
            % For cold
            c = self.chevronAngle; 
            r = self.reynoldsColdPC;
            e = self.enlargementFactor;
            p = KF.waterValues("pn", self.TAvgCold);
            
            self.nusseltNumberCold = (0.2668 - 0.006967 * c + 7.244 * 10^-5 * c^2) * ...
                (20.78 - 50.94 * e + 41.1 * e^2 - 10.51 * e^3) * ...
                r^(0.728 + 0.0543 * sin((pi * c / 45 + 3.7))) * p^(1/3);
            
            self.frictionFactorCold = (2.917 - 0.1277 * c + 2.016 * 10^-3 * c^2)*...
                (5.474 - 19.02 * e + 18.93 * e^2 - 5.341 * e^3)*...
                r^(-(0.2 + 0.0577 * sin(pi * c / 45 + 2.1)));
            
            % For hot
            r = self.reynoldsHotPC;
            p = KF.waterValues("pn", self.TAvgHot);
            
            self.nusseltNumberHot = (0.2668 - 0.006967 * c + 7.244 * 10^-5 * c^2) * ...
                (20.78 - 50.94 * e + 41.1 * e^2 - 10.51 * e^3) * ...
                r^(0.728 + 0.0543 * sin((pi * c / 45) + 3.7)) * p^(1/3);
            
            self.frictionFactorHot = (2.917 - 0.1277 * c + 2.016 * 10^-3 * c^2)*...
                (5.474 - 19.02 * e + 18.93 * e^2 - 5.341 * e^3)*...
                r^(-(0.2 + 0.0577 * sin((pi * c / 45) + 2.1)));
        end
    end
end

