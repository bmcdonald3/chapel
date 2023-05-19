//===-- SPIRVGlobalRegistry.cpp - SPIR-V Global Registry --------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file contains the implementation of the SPIRVGlobalRegistry class,
// which is used to maintain rich type information required for SPIR-V even
// after lowering from LLVM IR to GMIR. It can convert an llvm::Type into
// an OpTypeXXX instruction, and map it to a virtual register. Also it builds
// and supports consistency of constants and global variables.
//
//===----------------------------------------------------------------------===//

#include "SPIRVGlobalRegistry.h"
#include "SPIRV.h"
#include "SPIRVSubtarget.h"
#include "SPIRVTargetMachine.h"
#include "SPIRVUtils.h"

using namespace llvm;
SPIRVGlobalRegistry::SPIRVGlobalRegistry(unsigned PointerSize)
    : PointerSize(PointerSize) {}

SPIRVType *SPIRVGlobalRegistry::assignIntTypeToVReg(unsigned BitWidth,
                                                    Register VReg,
                                                    MachineInstr &I,
                                                    const SPIRVInstrInfo &TII) {
  SPIRVType *SpirvType = getOrCreateSPIRVIntegerType(BitWidth, I, TII);
  assignSPIRVTypeToVReg(SpirvType, VReg, *CurMF);
  return SpirvType;
}

SPIRVType *SPIRVGlobalRegistry::assignVectTypeToVReg(
    SPIRVType *BaseType, unsigned NumElements, Register VReg, MachineInstr &I,
    const SPIRVInstrInfo &TII) {
  SPIRVType *SpirvType =
      getOrCreateSPIRVVectorType(BaseType, NumElements, I, TII);
  assignSPIRVTypeToVReg(SpirvType, VReg, *CurMF);
  return SpirvType;
}

SPIRVType *SPIRVGlobalRegistry::assignTypeToVReg(
    const Type *Type, Register VReg, MachineIRBuilder &MIRBuilder,
    SPIRV::AccessQualifier AccessQual, bool EmitIR) {

  SPIRVType *SpirvType =
      getOrCreateSPIRVType(Type, MIRBuilder, AccessQual, EmitIR);
  assignSPIRVTypeToVReg(SpirvType, VReg, MIRBuilder.getMF());
  return SpirvType;
}

void SPIRVGlobalRegistry::assignSPIRVTypeToVReg(SPIRVType *SpirvType,
                                                Register VReg,
                                                MachineFunction &MF) {
  VRegToTypeMap[&MF][VReg] = SpirvType;
}

static Register createTypeVReg(MachineIRBuilder &MIRBuilder) {
  auto &MRI = MIRBuilder.getMF().getRegInfo();
  auto Res = MRI.createGenericVirtualRegister(LLT::scalar(32));
  MRI.setRegClass(Res, &SPIRV::TYPERegClass);
  return Res;
}

static Register createTypeVReg(MachineRegisterInfo &MRI) {
  auto Res = MRI.createGenericVirtualRegister(LLT::scalar(32));
  MRI.setRegClass(Res, &SPIRV::TYPERegClass);
  return Res;
}

SPIRVType *SPIRVGlobalRegistry::getOpTypeBool(MachineIRBuilder &MIRBuilder) {
  return MIRBuilder.buildInstr(SPIRV::OpTypeBool)
      .addDef(createTypeVReg(MIRBuilder));
}

SPIRVType *SPIRVGlobalRegistry::getOpTypeInt(uint32_t Width,
                                             MachineIRBuilder &MIRBuilder,
                                             bool IsSigned) {
  auto MIB = MIRBuilder.buildInstr(SPIRV::OpTypeInt)
                 .addDef(createTypeVReg(MIRBuilder))
                 .addImm(Width)
                 .addImm(IsSigned ? 1 : 0);
  return MIB;
}

SPIRVType *SPIRVGlobalRegistry::getOpTypeFloat(uint32_t Width,
                                               MachineIRBuilder &MIRBuilder) {
  auto MIB = MIRBuilder.buildInstr(SPIRV::OpTypeFloat)
                 .addDef(createTypeVReg(MIRBuilder))
                 .addImm(Width);
  return MIB;
}

SPIRVType *SPIRVGlobalRegistry::getOpTypeVoid(MachineIRBuilder &MIRBuilder) {
  return MIRBuilder.buildInstr(SPIRV::OpTypeVoid)
      .addDef(createTypeVReg(MIRBuilder));
}

SPIRVType *SPIRVGlobalRegistry::getOpTypeVector(uint32_t NumElems,
                                                SPIRVType *ElemType,
                                                MachineIRBuilder &MIRBuilder) {
  auto EleOpc = ElemType->getOpcode();
  assert((EleOpc == SPIRV::OpTypeInt || EleOpc == SPIRV::OpTypeFloat ||
          EleOpc == SPIRV::OpTypeBool) &&
         "Invalid vector element type");

  auto MIB = MIRBuilder.buildInstr(SPIRV::OpTypeVector)
                 .addDef(createTypeVReg(MIRBuilder))
                 .addUse(getSPIRVTypeID(ElemType))
                 .addImm(NumElems);
  return MIB;
}

std::tuple<Register, ConstantInt *, bool>
SPIRVGlobalRegistry::getOrCreateConstIntReg(uint64_t Val, SPIRVType *SpvType,
                                            MachineIRBuilder *MIRBuilder,
                                            MachineInstr *I,
                                            const SPIRVInstrInfo *TII) {
  const IntegerType *LLVMIntTy;
  if (SpvType)
    LLVMIntTy = cast<IntegerType>(getTypeForSPIRVType(SpvType));
  else
    LLVMIntTy = IntegerType::getInt32Ty(CurMF->getFunction().getContext());
  bool NewInstr = false;
  // Find a constant in DT or build a new one.
  ConstantInt *CI = ConstantInt::get(const_cast<IntegerType *>(LLVMIntTy), Val);
  Register Res = DT.find(CI, CurMF);
  if (!Res.isValid()) {
    unsigned BitWidth = SpvType ? getScalarOrVectorBitWidth(SpvType) : 32;
    LLT LLTy = LLT::scalar(32);
    Res = CurMF->getRegInfo().createGenericVirtualRegister(LLTy);
    if (MIRBuilder)
      assignTypeToVReg(LLVMIntTy, Res, *MIRBuilder);
    else
      assignIntTypeToVReg(BitWidth, Res, *I, *TII);
    DT.add(CI, CurMF, Res);
    NewInstr = true;
  }
  return std::make_tuple(Res, CI, NewInstr);
}

Register SPIRVGlobalRegistry::getOrCreateConstInt(uint64_t Val, MachineInstr &I,
                                                  SPIRVType *SpvType,
                                                  const SPIRVInstrInfo &TII) {
  assert(SpvType);
  ConstantInt *CI;
  Register Res;
  bool New;
  std::tie(Res, CI, New) =
      getOrCreateConstIntReg(Val, SpvType, nullptr, &I, &TII);
  // If we have found Res register which is defined by the passed G_CONSTANT
  // machine instruction, a new constant instruction should be created.
  if (!New && (!I.getOperand(0).isReg() || Res != I.getOperand(0).getReg()))
    return Res;
  MachineInstrBuilder MIB;
  MachineBasicBlock &BB = *I.getParent();
  if (Val) {
    MIB = BuildMI(BB, I, I.getDebugLoc(), TII.get(SPIRV::OpConstantI))
              .addDef(Res)
              .addUse(getSPIRVTypeID(SpvType));
    addNumImm(APInt(getScalarOrVectorBitWidth(SpvType), Val), MIB);
  } else {
    MIB = BuildMI(BB, I, I.getDebugLoc(), TII.get(SPIRV::OpConstantNull))
              .addDef(Res)
              .addUse(getSPIRVTypeID(SpvType));
  }
  const auto &ST = CurMF->getSubtarget();
  constrainSelectedInstRegOperands(*MIB, *ST.getInstrInfo(),
                                   *ST.getRegisterInfo(), *ST.getRegBankInfo());
  return Res;
}

Register SPIRVGlobalRegistry::buildConstantInt(uint64_t Val,
                                               MachineIRBuilder &MIRBuilder,
                                               SPIRVType *SpvType,
                                               bool EmitIR) {
  auto &MF = MIRBuilder.getMF();
  const IntegerType *LLVMIntTy;
  if (SpvType)
    LLVMIntTy = cast<IntegerType>(getTypeForSPIRVType(SpvType));
  else
    LLVMIntTy = IntegerType::getInt32Ty(MF.getFunction().getContext());
  // Find a constant in DT or build a new one.
  const auto ConstInt =
      ConstantInt::get(const_cast<IntegerType *>(LLVMIntTy), Val);
  Register Res = DT.find(ConstInt, &MF);
  if (!Res.isValid()) {
    unsigned BitWidth = SpvType ? getScalarOrVectorBitWidth(SpvType) : 32;
    LLT LLTy = LLT::scalar(EmitIR ? BitWidth : 32);
    Res = MF.getRegInfo().createGenericVirtualRegister(LLTy);
    assignTypeToVReg(LLVMIntTy, Res, MIRBuilder,
                     SPIRV::AccessQualifier::ReadWrite, EmitIR);
    DT.add(ConstInt, &MIRBuilder.getMF(), Res);
    if (EmitIR) {
      MIRBuilder.buildConstant(Res, *ConstInt);
    } else {
      MachineInstrBuilder MIB;
      if (Val) {
        assert(SpvType);
        MIB = MIRBuilder.buildInstr(SPIRV::OpConstantI)
                  .addDef(Res)
                  .addUse(getSPIRVTypeID(SpvType));
        addNumImm(APInt(BitWidth, Val), MIB);
      } else {
        assert(SpvType);
        MIB = MIRBuilder.buildInstr(SPIRV::OpConstantNull)
                  .addDef(Res)
                  .addUse(getSPIRVTypeID(SpvType));
      }
      const auto &Subtarget = CurMF->getSubtarget();
      constrainSelectedInstRegOperands(*MIB, *Subtarget.getInstrInfo(),
                                       *Subtarget.getRegisterInfo(),
                                       *Subtarget.getRegBankInfo());
    }
  }
  return Res;
}

Register SPIRVGlobalRegistry::buildConstantFP(APFloat Val,
                                              MachineIRBuilder &MIRBuilder,
                                              SPIRVType *SpvType) {
  auto &MF = MIRBuilder.getMF();
  const Type *LLVMFPTy;
  if (SpvType) {
    LLVMFPTy = getTypeForSPIRVType(SpvType);
    assert(LLVMFPTy->isFloatingPointTy());
  } else {
    LLVMFPTy = IntegerType::getFloatTy(MF.getFunction().getContext());
  }
  // Find a constant in DT or build a new one.
  const auto ConstFP = ConstantFP::get(LLVMFPTy->getContext(), Val);
  Register Res = DT.find(ConstFP, &MF);
  if (!Res.isValid()) {
    unsigned BitWidth = SpvType ? getScalarOrVectorBitWidth(SpvType) : 32;
    Res = MF.getRegInfo().createGenericVirtualRegister(LLT::scalar(BitWidth));
    assignTypeToVReg(LLVMFPTy, Res, MIRBuilder);
    DT.add(ConstFP, &MF, Res);
    MIRBuilder.buildFConstant(Res, *ConstFP);
  }
  return Res;
}

Register
SPIRVGlobalRegistry::getOrCreateConsIntVector(uint64_t Val, MachineInstr &I,
                                              SPIRVType *SpvType,
                                              const SPIRVInstrInfo &TII) {
  const Type *LLVMTy = getTypeForSPIRVType(SpvType);
  assert(LLVMTy->isVectorTy());
  const FixedVectorType *LLVMVecTy = cast<FixedVectorType>(LLVMTy);
  Type *LLVMBaseTy = LLVMVecTy->getElementType();
  // Find a constant vector in DT or build a new one.
  const auto ConstInt = ConstantInt::get(LLVMBaseTy, Val);
  auto ConstVec =
      ConstantVector::getSplat(LLVMVecTy->getElementCount(), ConstInt);
  Register Res = DT.find(ConstVec, CurMF);
  if (!Res.isValid()) {
    unsigned BitWidth = getScalarOrVectorBitWidth(SpvType);
    SPIRVType *SpvBaseType = getOrCreateSPIRVIntegerType(BitWidth, I, TII);
    // SpvScalConst should be created before SpvVecConst to avoid undefined ID
    // error on validation.
    // TODO: can moved below once sorting of types/consts/defs is implemented.
    Register SpvScalConst;
    if (Val)
      SpvScalConst = getOrCreateConstInt(Val, I, SpvBaseType, TII);
    // TODO: maybe use bitwidth of base type.
    LLT LLTy = LLT::scalar(32);
    Register SpvVecConst =
        CurMF->getRegInfo().createGenericVirtualRegister(LLTy);
    const unsigned ElemCnt = SpvType->getOperand(2).getImm();
    assignVectTypeToVReg(SpvBaseType, ElemCnt, SpvVecConst, I, TII);
    DT.add(ConstVec, CurMF, SpvVecConst);
    MachineInstrBuilder MIB;
    MachineBasicBlock &BB = *I.getParent();
    if (Val) {
      MIB = BuildMI(BB, I, I.getDebugLoc(), TII.get(SPIRV::OpConstantComposite))
                .addDef(SpvVecConst)
                .addUse(getSPIRVTypeID(SpvType));
      for (unsigned i = 0; i < ElemCnt; ++i)
        MIB.addUse(SpvScalConst);
    } else {
      MIB = BuildMI(BB, I, I.getDebugLoc(), TII.get(SPIRV::OpConstantNull))
                .addDef(SpvVecConst)
                .addUse(getSPIRVTypeID(SpvType));
    }
    const auto &Subtarget = CurMF->getSubtarget();
    constrainSelectedInstRegOperands(*MIB, *Subtarget.getInstrInfo(),
                                     *Subtarget.getRegisterInfo(),
                                     *Subtarget.getRegBankInfo());
    return SpvVecConst;
  }
  return Res;
}

Register SPIRVGlobalRegistry::buildGlobalVariable(
    Register ResVReg, SPIRVType *BaseType, StringRef Name,
    const GlobalValue *GV, SPIRV::StorageClass Storage,
    const MachineInstr *Init, bool IsConst, bool HasLinkageTy,
    SPIRV::LinkageType LinkageType, MachineIRBuilder &MIRBuilder,
    bool IsInstSelector) {
  const GlobalVariable *GVar = nullptr;
  if (GV)
    GVar = cast<const GlobalVariable>(GV);
  else {
    // If GV is not passed explicitly, use the name to find or construct
    // the global variable.
    Module *M = MIRBuilder.getMF().getFunction().getParent();
    GVar = M->getGlobalVariable(Name);
    if (GVar == nullptr) {
      const Type *Ty = getTypeForSPIRVType(BaseType); // TODO: check type.
      GVar = new GlobalVariable(*M, const_cast<Type *>(Ty), false,
                                GlobalValue::ExternalLinkage, nullptr,
                                Twine(Name));
    }
    GV = GVar;
  }
  Register Reg = DT.find(GVar, &MIRBuilder.getMF());
  if (Reg.isValid()) {
    if (Reg != ResVReg)
      MIRBuilder.buildCopy(ResVReg, Reg);
    return ResVReg;
  }

  auto MIB = MIRBuilder.buildInstr(SPIRV::OpVariable)
                 .addDef(ResVReg)
                 .addUse(getSPIRVTypeID(BaseType))
                 .addImm(static_cast<uint32_t>(Storage));

  if (Init != 0) {
    MIB.addUse(Init->getOperand(0).getReg());
  }

  // ISel may introduce a new register on this step, so we need to add it to
  // DT and correct its type avoiding fails on the next stage.
  if (IsInstSelector) {
    const auto &Subtarget = CurMF->getSubtarget();
    constrainSelectedInstRegOperands(*MIB, *Subtarget.getInstrInfo(),
                                     *Subtarget.getRegisterInfo(),
                                     *Subtarget.getRegBankInfo());
  }
  Reg = MIB->getOperand(0).getReg();
  DT.add(GVar, &MIRBuilder.getMF(), Reg);

  // Set to Reg the same type as ResVReg has.
  auto MRI = MIRBuilder.getMRI();
  assert(MRI->getType(ResVReg).isPointer() && "Pointer type is expected");
  if (Reg != ResVReg) {
    LLT RegLLTy = LLT::pointer(MRI->getType(ResVReg).getAddressSpace(), 32);
    MRI->setType(Reg, RegLLTy);
    assignSPIRVTypeToVReg(BaseType, Reg, MIRBuilder.getMF());
  }

  // If it's a global variable with name, output OpName for it.
  if (GVar && GVar->hasName())
    buildOpName(Reg, GVar->getName(), MIRBuilder);

  // Output decorations for the GV.
  // TODO: maybe move to GenerateDecorations pass.
  if (IsConst)
    buildOpDecorate(Reg, MIRBuilder, SPIRV::Decoration::Constant, {});

  if (GVar && GVar->getAlign().valueOrOne().value() != 1)
    buildOpDecorate(
        Reg, MIRBuilder, SPIRV::Decoration::Alignment,
        {static_cast<uint32_t>(GVar->getAlign().valueOrOne().value())});

  if (HasLinkageTy)
    buildOpDecorate(Reg, MIRBuilder, SPIRV::Decoration::LinkageAttributes,
                    {static_cast<uint32_t>(LinkageType)}, Name);
  return Reg;
}

SPIRVType *SPIRVGlobalRegistry::getOpTypeArray(uint32_t NumElems,
                                               SPIRVType *ElemType,
                                               MachineIRBuilder &MIRBuilder,
                                               bool EmitIR) {
  assert((ElemType->getOpcode() != SPIRV::OpTypeVoid) &&
         "Invalid array element type");
  Register NumElementsVReg =
      buildConstantInt(NumElems, MIRBuilder, nullptr, EmitIR);
  auto MIB = MIRBuilder.buildInstr(SPIRV::OpTypeArray)
                 .addDef(createTypeVReg(MIRBuilder))
                 .addUse(getSPIRVTypeID(ElemType))
                 .addUse(NumElementsVReg);
  return MIB;
}

SPIRVType *SPIRVGlobalRegistry::getOpTypeOpaque(const StructType *Ty,
                                                MachineIRBuilder &MIRBuilder) {
  assert(Ty->hasName());
  const StringRef Name = Ty->hasName() ? Ty->getName() : "";
  Register ResVReg = createTypeVReg(MIRBuilder);
  auto MIB = MIRBuilder.buildInstr(SPIRV::OpTypeOpaque).addDef(ResVReg);
  addStringImm(Name, MIB);
  buildOpName(ResVReg, Name, MIRBuilder);
  return MIB;
}

SPIRVType *SPIRVGlobalRegistry::getOpTypeStruct(const StructType *Ty,
                                                MachineIRBuilder &MIRBuilder,
                                                bool EmitIR) {
  SmallVector<Register, 4> FieldTypes;
  for (const auto &Elem : Ty->elements()) {
    SPIRVType *ElemTy = findSPIRVType(Elem, MIRBuilder);
    assert(ElemTy && ElemTy->getOpcode() != SPIRV::OpTypeVoid &&
           "Invalid struct element type");
    FieldTypes.push_back(getSPIRVTypeID(ElemTy));
  }
  Register ResVReg = createTypeVReg(MIRBuilder);
  auto MIB = MIRBuilder.buildInstr(SPIRV::OpTypeStruct).addDef(ResVReg);
  for (const auto &Ty : FieldTypes)
    MIB.addUse(Ty);
  if (Ty->hasName())
    buildOpName(ResVReg, Ty->getName(), MIRBuilder);
  if (Ty->isPacked())
    buildOpDecorate(ResVReg, MIRBuilder, SPIRV::Decoration::CPacked, {});
  return MIB;
}

static bool isOpenCLBuiltinType(const StructType *SType) {
  return SType->isOpaque() && SType->hasName() &&
         SType->getName().startswith("opencl.");
}

static bool isSPIRVBuiltinType(const StructType *SType) {
  return SType->isOpaque() && SType->hasName() &&
         SType->getName().startswith("spirv.");
}

static bool isSpecialType(const Type *Ty) {
  if (auto PType = dyn_cast<PointerType>(Ty)) {
    if (!PType->isOpaque())
      Ty = PType->getNonOpaquePointerElementType();
  }
  if (auto SType = dyn_cast<StructType>(Ty))
    return isOpenCLBuiltinType(SType) || isSPIRVBuiltinType(SType);
  return false;
}

SPIRVType *SPIRVGlobalRegistry::getOpTypePointer(SPIRV::StorageClass SC,
                                                 SPIRVType *ElemType,
                                                 MachineIRBuilder &MIRBuilder,
                                                 Register Reg) {
  if (!Reg.isValid())
    Reg = createTypeVReg(MIRBuilder);
  return MIRBuilder.buildInstr(SPIRV::OpTypePointer)
      .addDef(Reg)
      .addImm(static_cast<uint32_t>(SC))
      .addUse(getSPIRVTypeID(ElemType));
}

SPIRVType *
SPIRVGlobalRegistry::getOpTypeForwardPointer(SPIRV::StorageClass SC,
                                             MachineIRBuilder &MIRBuilder) {
  return MIRBuilder.buildInstr(SPIRV::OpTypeForwardPointer)
      .addUse(createTypeVReg(MIRBuilder))
      .addImm(static_cast<uint32_t>(SC));
}

SPIRVType *SPIRVGlobalRegistry::getOpTypeFunction(
    SPIRVType *RetType, const SmallVectorImpl<SPIRVType *> &ArgTypes,
    MachineIRBuilder &MIRBuilder) {
  auto MIB = MIRBuilder.buildInstr(SPIRV::OpTypeFunction)
                 .addDef(createTypeVReg(MIRBuilder))
                 .addUse(getSPIRVTypeID(RetType));
  for (const SPIRVType *ArgType : ArgTypes)
    MIB.addUse(getSPIRVTypeID(ArgType));
  return MIB;
}

SPIRVType *SPIRVGlobalRegistry::getOrCreateOpTypeFunctionWithArgs(
    const Type *Ty, SPIRVType *RetType,
    const SmallVectorImpl<SPIRVType *> &ArgTypes,
    MachineIRBuilder &MIRBuilder) {
  Register Reg = DT.find(Ty, &MIRBuilder.getMF());
  if (Reg.isValid())
    return getSPIRVTypeForVReg(Reg);
  SPIRVType *SpirvType = getOpTypeFunction(RetType, ArgTypes, MIRBuilder);
  return finishCreatingSPIRVType(Ty, SpirvType);
}

SPIRVType *SPIRVGlobalRegistry::findSPIRVType(const Type *Ty,
                                              MachineIRBuilder &MIRBuilder,
                                              SPIRV::AccessQualifier AccQual,
                                              bool EmitIR) {
  Register Reg = DT.find(Ty, &MIRBuilder.getMF());
  if (Reg.isValid())
    return getSPIRVTypeForVReg(Reg);
  if (ForwardPointerTypes.find(Ty) != ForwardPointerTypes.end())
    return ForwardPointerTypes[Ty];
  return restOfCreateSPIRVType(Ty, MIRBuilder, AccQual, EmitIR);
}

Register SPIRVGlobalRegistry::getSPIRVTypeID(const SPIRVType *SpirvType) const {
  assert(SpirvType && "Attempting to get type id for nullptr type.");
  if (SpirvType->getOpcode() == SPIRV::OpTypeForwardPointer)
    return SpirvType->uses().begin()->getReg();
  return SpirvType->defs().begin()->getReg();
}

SPIRVType *SPIRVGlobalRegistry::createSPIRVType(const Type *Ty,
                                                MachineIRBuilder &MIRBuilder,
                                                SPIRV::AccessQualifier AccQual,
                                                bool EmitIR) {
  assert(!isSpecialType(Ty));
  auto &TypeToSPIRVTypeMap = DT.getTypes()->getAllUses();
  auto t = TypeToSPIRVTypeMap.find(Ty);
  if (t != TypeToSPIRVTypeMap.end()) {
    auto tt = t->second.find(&MIRBuilder.getMF());
    if (tt != t->second.end())
      return getSPIRVTypeForVReg(tt->second);
  }

  if (auto IType = dyn_cast<IntegerType>(Ty)) {
    const unsigned Width = IType->getBitWidth();
    return Width == 1 ? getOpTypeBool(MIRBuilder)
                      : getOpTypeInt(Width, MIRBuilder, false);
  }
  if (Ty->isFloatingPointTy())
    return getOpTypeFloat(Ty->getPrimitiveSizeInBits(), MIRBuilder);
  if (Ty->isVoidTy())
    return getOpTypeVoid(MIRBuilder);
  if (Ty->isVectorTy()) {
    SPIRVType *El =
        findSPIRVType(cast<FixedVectorType>(Ty)->getElementType(), MIRBuilder);
    return getOpTypeVector(cast<FixedVectorType>(Ty)->getNumElements(), El,
                           MIRBuilder);
  }
  if (Ty->isArrayTy()) {
    SPIRVType *El = findSPIRVType(Ty->getArrayElementType(), MIRBuilder);
    return getOpTypeArray(Ty->getArrayNumElements(), El, MIRBuilder, EmitIR);
  }
  if (auto SType = dyn_cast<StructType>(Ty)) {
    if (SType->isOpaque())
      return getOpTypeOpaque(SType, MIRBuilder);
    return getOpTypeStruct(SType, MIRBuilder, EmitIR);
  }
  if (auto FType = dyn_cast<FunctionType>(Ty)) {
    SPIRVType *RetTy = findSPIRVType(FType->getReturnType(), MIRBuilder);
    SmallVector<SPIRVType *, 4> ParamTypes;
    for (const auto &t : FType->params()) {
      ParamTypes.push_back(findSPIRVType(t, MIRBuilder));
    }
    return getOpTypeFunction(RetTy, ParamTypes, MIRBuilder);
  }
  if (auto PType = dyn_cast<PointerType>(Ty)) {
    SPIRVType *SpvElementType;
    // At the moment, all opaque pointers correspond to i8 element type.
    // TODO: change the implementation once opaque pointers are supported
    // in the SPIR-V specification.
    if (PType->isOpaque())
      SpvElementType = getOrCreateSPIRVIntegerType(8, MIRBuilder);
    else
      SpvElementType =
          findSPIRVType(PType->getNonOpaquePointerElementType(), MIRBuilder,
                        SPIRV::AccessQualifier::ReadWrite, EmitIR);
    auto SC = addressSpaceToStorageClass(PType->getAddressSpace());
    // Null pointer means we have a loop in type definitions, make and
    // return corresponding OpTypeForwardPointer.
    if (SpvElementType == nullptr) {
      if (ForwardPointerTypes.find(Ty) == ForwardPointerTypes.end())
        ForwardPointerTypes[PType] = getOpTypeForwardPointer(SC, MIRBuilder);
      return ForwardPointerTypes[PType];
    }
    Register Reg(0);
    // If we have forward pointer associated with this type, use its register
    // operand to create OpTypePointer.
    if (ForwardPointerTypes.find(PType) != ForwardPointerTypes.end())
      Reg = getSPIRVTypeID(ForwardPointerTypes[PType]);

    return getOpTypePointer(SC, SpvElementType, MIRBuilder, Reg);
  }
  llvm_unreachable("Unable to convert LLVM type to SPIRVType");
}

SPIRVType *SPIRVGlobalRegistry::restOfCreateSPIRVType(
    const Type *Ty, MachineIRBuilder &MIRBuilder,
    SPIRV::AccessQualifier AccessQual, bool EmitIR) {
  if (TypesInProcessing.count(Ty) && !Ty->isPointerTy())
    return nullptr;
  TypesInProcessing.insert(Ty);
  SPIRVType *SpirvType = createSPIRVType(Ty, MIRBuilder, AccessQual, EmitIR);
  TypesInProcessing.erase(Ty);
  VRegToTypeMap[&MIRBuilder.getMF()][getSPIRVTypeID(SpirvType)] = SpirvType;
  SPIRVToLLVMType[SpirvType] = Ty;
  Register Reg = DT.find(Ty, &MIRBuilder.getMF());
  // Do not add OpTypeForwardPointer to DT, a corresponding normal pointer type
  // will be added later. For special types it is already added to DT.
  if (SpirvType->getOpcode() != SPIRV::OpTypeForwardPointer && !Reg.isValid() &&
      !isSpecialType(Ty))
    DT.add(Ty, &MIRBuilder.getMF(), getSPIRVTypeID(SpirvType));

  return SpirvType;
}

SPIRVType *SPIRVGlobalRegistry::getSPIRVTypeForVReg(Register VReg) const {
  auto t = VRegToTypeMap.find(CurMF);
  if (t != VRegToTypeMap.end()) {
    auto tt = t->second.find(VReg);
    if (tt != t->second.end())
      return tt->second;
  }
  return nullptr;
}

SPIRVType *SPIRVGlobalRegistry::getOrCreateSPIRVType(
    const Type *Ty, MachineIRBuilder &MIRBuilder,
    SPIRV::AccessQualifier AccessQual, bool EmitIR) {
  Register Reg = DT.find(Ty, &MIRBuilder.getMF());
  if (Reg.isValid())
    return getSPIRVTypeForVReg(Reg);
  TypesInProcessing.clear();
  SPIRVType *STy = restOfCreateSPIRVType(Ty, MIRBuilder, AccessQual, EmitIR);
  // Create normal pointer types for the corresponding OpTypeForwardPointers.
  for (auto &CU : ForwardPointerTypes) {
    const Type *Ty2 = CU.first;
    SPIRVType *STy2 = CU.second;
    if ((Reg = DT.find(Ty2, &MIRBuilder.getMF())).isValid())
      STy2 = getSPIRVTypeForVReg(Reg);
    else
      STy2 = restOfCreateSPIRVType(Ty2, MIRBuilder, AccessQual, EmitIR);
    if (Ty == Ty2)
      STy = STy2;
  }
  ForwardPointerTypes.clear();
  return STy;
}

bool SPIRVGlobalRegistry::isScalarOfType(Register VReg,
                                         unsigned TypeOpcode) const {
  SPIRVType *Type = getSPIRVTypeForVReg(VReg);
  assert(Type && "isScalarOfType VReg has no type assigned");
  return Type->getOpcode() == TypeOpcode;
}

bool SPIRVGlobalRegistry::isScalarOrVectorOfType(Register VReg,
                                                 unsigned TypeOpcode) const {
  SPIRVType *Type = getSPIRVTypeForVReg(VReg);
  assert(Type && "isScalarOrVectorOfType VReg has no type assigned");
  if (Type->getOpcode() == TypeOpcode)
    return true;
  if (Type->getOpcode() == SPIRV::OpTypeVector) {
    Register ScalarTypeVReg = Type->getOperand(1).getReg();
    SPIRVType *ScalarType = getSPIRVTypeForVReg(ScalarTypeVReg);
    return ScalarType->getOpcode() == TypeOpcode;
  }
  return false;
}

unsigned
SPIRVGlobalRegistry::getScalarOrVectorBitWidth(const SPIRVType *Type) const {
  assert(Type && "Invalid Type pointer");
  if (Type->getOpcode() == SPIRV::OpTypeVector) {
    auto EleTypeReg = Type->getOperand(1).getReg();
    Type = getSPIRVTypeForVReg(EleTypeReg);
  }
  if (Type->getOpcode() == SPIRV::OpTypeInt ||
      Type->getOpcode() == SPIRV::OpTypeFloat)
    return Type->getOperand(1).getImm();
  if (Type->getOpcode() == SPIRV::OpTypeBool)
    return 1;
  llvm_unreachable("Attempting to get bit width of non-integer/float type.");
}

bool SPIRVGlobalRegistry::isScalarOrVectorSigned(const SPIRVType *Type) const {
  assert(Type && "Invalid Type pointer");
  if (Type->getOpcode() == SPIRV::OpTypeVector) {
    auto EleTypeReg = Type->getOperand(1).getReg();
    Type = getSPIRVTypeForVReg(EleTypeReg);
  }
  if (Type->getOpcode() == SPIRV::OpTypeInt)
    return Type->getOperand(2).getImm() != 0;
  llvm_unreachable("Attempting to get sign of non-integer type.");
}

SPIRV::StorageClass
SPIRVGlobalRegistry::getPointerStorageClass(Register VReg) const {
  SPIRVType *Type = getSPIRVTypeForVReg(VReg);
  assert(Type && Type->getOpcode() == SPIRV::OpTypePointer &&
         Type->getOperand(1).isImm() && "Pointer type is expected");
  return static_cast<SPIRV::StorageClass>(Type->getOperand(1).getImm());
}

SPIRVType *
SPIRVGlobalRegistry::getOrCreateSPIRVIntegerType(unsigned BitWidth,
                                                 MachineIRBuilder &MIRBuilder) {
  return getOrCreateSPIRVType(
      IntegerType::get(MIRBuilder.getMF().getFunction().getContext(), BitWidth),
      MIRBuilder);
}

SPIRVType *SPIRVGlobalRegistry::finishCreatingSPIRVType(const Type *LLVMTy,
                                                        SPIRVType *SpirvType) {
  assert(CurMF == SpirvType->getMF());
  VRegToTypeMap[CurMF][getSPIRVTypeID(SpirvType)] = SpirvType;
  SPIRVToLLVMType[SpirvType] = LLVMTy;
  DT.add(LLVMTy, CurMF, getSPIRVTypeID(SpirvType));
  return SpirvType;
}

SPIRVType *SPIRVGlobalRegistry::getOrCreateSPIRVIntegerType(
    unsigned BitWidth, MachineInstr &I, const SPIRVInstrInfo &TII) {
  Type *LLVMTy = IntegerType::get(CurMF->getFunction().getContext(), BitWidth);
  Register Reg = DT.find(LLVMTy, CurMF);
  if (Reg.isValid())
    return getSPIRVTypeForVReg(Reg);
  MachineBasicBlock &BB = *I.getParent();
  auto MIB = BuildMI(BB, I, I.getDebugLoc(), TII.get(SPIRV::OpTypeInt))
                 .addDef(createTypeVReg(CurMF->getRegInfo()))
                 .addImm(BitWidth)
                 .addImm(0);
  return finishCreatingSPIRVType(LLVMTy, MIB);
}

SPIRVType *
SPIRVGlobalRegistry::getOrCreateSPIRVBoolType(MachineIRBuilder &MIRBuilder) {
  return getOrCreateSPIRVType(
      IntegerType::get(MIRBuilder.getMF().getFunction().getContext(), 1),
      MIRBuilder);
}

SPIRVType *
SPIRVGlobalRegistry::getOrCreateSPIRVBoolType(MachineInstr &I,
                                              const SPIRVInstrInfo &TII) {
  Type *LLVMTy = IntegerType::get(CurMF->getFunction().getContext(), 1);
  Register Reg = DT.find(LLVMTy, CurMF);
  if (Reg.isValid())
    return getSPIRVTypeForVReg(Reg);
  MachineBasicBlock &BB = *I.getParent();
  auto MIB = BuildMI(BB, I, I.getDebugLoc(), TII.get(SPIRV::OpTypeBool))
                 .addDef(createTypeVReg(CurMF->getRegInfo()));
  return finishCreatingSPIRVType(LLVMTy, MIB);
}

SPIRVType *SPIRVGlobalRegistry::getOrCreateSPIRVVectorType(
    SPIRVType *BaseType, unsigned NumElements, MachineIRBuilder &MIRBuilder) {
  return getOrCreateSPIRVType(
      FixedVectorType::get(const_cast<Type *>(getTypeForSPIRVType(BaseType)),
                           NumElements),
      MIRBuilder);
}

SPIRVType *SPIRVGlobalRegistry::getOrCreateSPIRVVectorType(
    SPIRVType *BaseType, unsigned NumElements, MachineInstr &I,
    const SPIRVInstrInfo &TII) {
  Type *LLVMTy = FixedVectorType::get(
      const_cast<Type *>(getTypeForSPIRVType(BaseType)), NumElements);
  Register Reg = DT.find(LLVMTy, CurMF);
  if (Reg.isValid())
    return getSPIRVTypeForVReg(Reg);
  MachineBasicBlock &BB = *I.getParent();
  auto MIB = BuildMI(BB, I, I.getDebugLoc(), TII.get(SPIRV::OpTypeVector))
                 .addDef(createTypeVReg(CurMF->getRegInfo()))
                 .addUse(getSPIRVTypeID(BaseType))
                 .addImm(NumElements);
  return finishCreatingSPIRVType(LLVMTy, MIB);
}

SPIRVType *
SPIRVGlobalRegistry::getOrCreateSPIRVPointerType(SPIRVType *BaseType,
                                                 MachineIRBuilder &MIRBuilder,
                                                 SPIRV::StorageClass SClass) {
  return getOrCreateSPIRVType(
      PointerType::get(const_cast<Type *>(getTypeForSPIRVType(BaseType)),
                       storageClassToAddressSpace(SClass)),
      MIRBuilder);
}

SPIRVType *SPIRVGlobalRegistry::getOrCreateSPIRVPointerType(
    SPIRVType *BaseType, MachineInstr &I, const SPIRVInstrInfo &TII,
    SPIRV::StorageClass SC) {
  Type *LLVMTy =
      PointerType::get(const_cast<Type *>(getTypeForSPIRVType(BaseType)),
                       storageClassToAddressSpace(SC));
  Register Reg = DT.find(LLVMTy, CurMF);
  if (Reg.isValid())
    return getSPIRVTypeForVReg(Reg);
  MachineBasicBlock &BB = *I.getParent();
  auto MIB = BuildMI(BB, I, I.getDebugLoc(), TII.get(SPIRV::OpTypePointer))
                 .addDef(createTypeVReg(CurMF->getRegInfo()))
                 .addImm(static_cast<uint32_t>(SC))
                 .addUse(getSPIRVTypeID(BaseType));
  return finishCreatingSPIRVType(LLVMTy, MIB);
}

Register SPIRVGlobalRegistry::getOrCreateUndef(MachineInstr &I,
                                               SPIRVType *SpvType,
                                               const SPIRVInstrInfo &TII) {
  assert(SpvType);
  const Type *LLVMTy = getTypeForSPIRVType(SpvType);
  assert(LLVMTy);
  // Find a constant in DT or build a new one.
  UndefValue *UV = UndefValue::get(const_cast<Type *>(LLVMTy));
  Register Res = DT.find(UV, CurMF);
  if (Res.isValid())
    return Res;
  LLT LLTy = LLT::scalar(32);
  Res = CurMF->getRegInfo().createGenericVirtualRegister(LLTy);
  assignSPIRVTypeToVReg(SpvType, Res, *CurMF);
  DT.add(UV, CurMF, Res);

  MachineInstrBuilder MIB;
  MIB = BuildMI(*I.getParent(), I, I.getDebugLoc(), TII.get(SPIRV::OpUndef))
            .addDef(Res)
            .addUse(getSPIRVTypeID(SpvType));
  const auto &ST = CurMF->getSubtarget();
  constrainSelectedInstRegOperands(*MIB, *ST.getInstrInfo(),
                                   *ST.getRegisterInfo(), *ST.getRegBankInfo());
  return Res;
}
