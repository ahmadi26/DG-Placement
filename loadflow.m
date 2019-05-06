function [P_loss,Bus_Voltage,q_loss]=loadflow(xx,branch,Loads)
V_Substation=1;
V_base=12.66;
S_Base=1000;
Z_Base=V_base^2/S_Base;
branch(:,4)=branch(:,4)/Z_Base;
branch(:,5)=branch(:,5)/Z_Base;
branch=sortrows(branch,3);



xxx=xx;
Loads(xxx(1,1),2)=Loads(xxx(1,1),2)-(xxx(1,1+7)); 
Loads(xxx(1,2),2)=Loads(xxx(1,2),2)-(xxx(1,2+7)); 
Loads(xxx(1,3),2)=Loads(xxx(1,3),2)-(xxx(1,3+7)); 
Loads(xxx(1,4),2)=Loads(xxx(1,4),2)-(xxx(1,4+7));
Loads(xxx(1,5),2)=Loads(xxx(1,5),2)-(xxx(1,5+7)); 
Loads(xxx(1,6),2)=Loads(xxx(1,6),2)-(xxx(1,6+7)); 
Loads(xxx(1,7),2)=Loads(xxx(1,7),2)-(xxx(1,7+7)); 


Loads(:,2)=Loads(:,2)/(1000*S_Base);
Loads(:,3)=Loads(:,3)/(1000*S_Base);
jay=sqrt(-1);
Number_of_Bus=max(Loads(:,1));
No_of_bus=Number_of_Bus;
Number_of_Branch=68;
Y_Bus=zeros(Number_of_Bus,Number_of_Bus);
for I_Ybus=1:Number_of_Branch
        Y_Bus(branch(I_Ybus,2),branch(I_Ybus,3))=Y_Bus(branch(I_Ybus,2),branch(I_Ybus,3))-1/(branch(I_Ybus,4)+jay*branch(I_Ybus,5));
        Y_Bus(branch(I_Ybus,3),branch(I_Ybus,2))=Y_Bus(branch(I_Ybus,2),branch(I_Ybus,3));
end
for I_Ybus=1:Number_of_Bus
    Y_Bus(I_Ybus,I_Ybus)=-sum(Y_Bus(I_Ybus,:));
end
Y_Bus_Ac=Y_Bus([2:Number_of_Bus],[2:Number_of_Bus]);
Y_Bus_Ac(1,1)=Y_Bus_Ac(1,1);%+1/(branch(1,4)+jay*branch(1,5));
Z_Bus=inv(Y_Bus_Ac);

DLF=Z_Bus;
Initial_Voltage=ones(No_of_bus-1,1)*V_Substation;
DLF_Itre_Max=12;
DLF_Itre =1;
Vector_Substation=V_Substation*ones(No_of_bus-1,1);
Voltage_1=Initial_Voltage;
Error=2;
while Error > 1e-4
    Load_Vector=1*(Loads([2:No_of_bus],2)+jay*Loads([2:No_of_bus],3));
    Current_Injection=conj(Load_Vector./Initial_Voltage);
    Delta_Voltage=(DLF*Current_Injection);
    Initial_Voltage=Vector_Substation-Delta_Voltage;
    Error=sqrt(sum((abs(Voltage_1-Initial_Voltage)).^2));
    Voltage_1=Initial_Voltage;
    DLF_Itre=DLF_Itre+1;
    if DLF_Itre >13
        break
    end
end
Angle_Ybus=angle(Y_Bus);
Ampliude_Ybus=abs(Y_Bus);
Bus_Voltage=abs([V_Substation;Initial_Voltage]);
Angle_Voltage=angle([V_Substation;Initial_Voltage]);
Min_Voltage=min(Bus_Voltage)/V_Substation;
Max_Voltage=max(Bus_Voltage)/V_Substation;
Psub=0;
Qsub=0;
for I_Sub=1:Number_of_Bus
    Psub=Psub+Bus_Voltage(1)*Bus_Voltage(I_Sub)*Ampliude_Ybus(1,I_Sub)*cos(Angle_Voltage(1)-Angle_Voltage(I_Sub)-Angle_Ybus(1,I_Sub));
    Qsub=Qsub+Bus_Voltage(1)*Bus_Voltage(I_Sub)*Ampliude_Ybus(1,I_Sub)*sin(Angle_Voltage(1)-Angle_Voltage(I_Sub)-Angle_Ybus(1,I_Sub));
end
Substaion=3*V_Substation*conj((V_Substation-Initial_Voltage(1))/(branch(1,4)+jay*branch(1,5)));
(V_Substation-Initial_Voltage(1))/(branch(1,4)+jay*branch(1,5));
Active_Load=sum(Loads([1:No_of_bus],2));
Reactive_Load=sum(Loads([1:No_of_bus],3));
Psubb=Psub;
Qsubb=Qsub;
Ploss=(Psubb-Active_Load);
qloss=(Qsubb-Reactive_Load);
if DLF_Itre >13
    Ploss=10000000;
    Psubb=100000000;
end
P_loss=Ploss*(1000*S_Base);  
Bus_Voltage;
q_loss=qloss*(1000*S_Base);
end