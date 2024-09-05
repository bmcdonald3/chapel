/*
 * Copyright 2021-2024 Hewlett Packard Enterprise Development LP
 * Other additional copyright holders may be indicated within.
 *
 * The entirety of this work is licensed under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 *
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#ifndef CHPL_LIB_RESOLUTION_RESOLVER_H
#define CHPL_LIB_RESOLUTION_RESOLVER_H

#include "chpl/resolution/resolution-types.h"
#include "chpl/uast/all-uast.h"
#include "InitResolver.h"

#include "llvm/ADT/ArrayRef.h"
#include "llvm/ADT/SmallVector.h"

namespace chpl {
namespace resolution {

struct Resolver {
  // types used below
  using ActionAndId = std::tuple<AssociatedAction::Action, ID>;

  /**
    When looking up matches for a particular identifier, we might encounter
    several. This is not always an error: specifically, we might be finding
    multiple parenless procedures, each with a potentially-false 'where' clause.

    This struct contains additional information to be returned from identifier
    lookup to help detect this case, and adjust the resolution strategy
    accordingly.
   */
  struct ParenlessOverloadInfo {
   private:
    /* Whether some of the parenless procedures were methods. This means the
       receiver type should be considered when resolving the call. */
    bool hasMethodCandidates_ = false;
    /* Whether some of the parenless procedures were not methods. This
       means non-method resolution should be attempted. */
    bool hasNonMethodCandidates_ = false;

    ParenlessOverloadInfo(bool hasMethodCandidates, bool hasNonMethodCandidates)
      : hasMethodCandidates_(hasMethodCandidates),
        hasNonMethodCandidates_(hasNonMethodCandidates) {}
   public:
    ParenlessOverloadInfo() = default;

    static ParenlessOverloadInfo fromMatchingIds(Context* context,
                                                 const MatchingIdsWithName&);

    bool areCandidatesOnlyParenlessProcs() const {
      // Note: constructor sets both to false when it discovers a single
      //       non-parenless candidate.
      return hasMethodCandidates_ || hasNonMethodCandidates_;
    }

    bool hasMethodCandidates() const { return hasMethodCandidates_; }
    bool hasNonMethodCandidates() const { return hasNonMethodCandidates_; }
  };

  // inputs to the resolution process
  Context* context = nullptr;
  const uast::AstNode* symbol = nullptr;
  const uast::AstNode* curStmt = nullptr;
  const types::CompositeType* inCompositeType = nullptr;
  const SubstitutionsMap* substitutions = nullptr;
  DefaultsPolicy defaultsPolicy = DefaultsPolicy::IGNORE_DEFAULTS;
  const TypedFnSignature* typedSignature = nullptr;
  const PoiScope* poiScope = nullptr;
  const uast::Decl* ignoreSubstitutionFor = nullptr;
  bool skipTypeQueries = false;

  // internal variables
  std::vector<const uast::Decl*> declStack;
  std::vector<const Scope*> scopeStack;
  std::vector<int> tagTracker;
  bool signatureOnly = false;
  bool fieldOrFormalsComputed = false;
  bool scopeResolveOnly = false;
  bool fieldTypesOnly = false;
  const uast::Block* fnBody = nullptr;
  std::set<ID> fieldOrFormals;
  std::set<ID> instantiatedFieldOrFormals;
  std::set<UniqueString> namesWithErrorsEmitted;
  std::vector<const uast::Call*> callNodeStack;
  std::vector<std::pair<UniqueString, const uast::AstNode*>> genericReceiverOverrideStack;

  bool allowReceiverScopes = false;
  bool receiverScopesComputed = false;
  ReceiverScopeSimpleHelper receiverScopeSimpleHelper;
  ReceiverScopeTypedHelper receiverScopeTypedHelper;
  const ReceiverScopeHelper* receiverScopeHelper = nullptr;

  // these are used for handling receiver scopes during forwarding expressions
  const MethodLookupHelper* forwardingLookupHelper = nullptr;

  Resolver* parentResolver = nullptr;
  owned<InitResolver> initResolver = nullptr;
  owned<OuterVariables> outerVars;

  // results of the resolution process

  // the resolution results for the contained AstNodes
  ResolutionResultByPostorderID& byPostorder;

  // the set of POI scopes from which POI functions were used --
  // these are gathered here during resolution in order to
  // allow accurate caching and reuse of instantiations
  PoiInfo poiInfo;

  // the return type of the function (inferred or not)
  types::QualifiedType returnType;

  static PoiInfo makePoiInfo(const PoiScope* poiScope) {
    if (poiScope == nullptr)
      return PoiInfo();

    return PoiInfo(poiScope);
  }

 private:
  Resolver(Context* context,
           const uast::AstNode* symbol,
           ResolutionResultByPostorderID& byPostorder,
           const PoiScope* poiScope)
    : context(context), symbol(symbol),
      poiScope(poiScope),
      byPostorder(byPostorder),
      poiInfo(makePoiInfo(poiScope)) {

    tagTracker.resize(uast::asttags::AstTag::NUM_AST_TAGS);
    enterScope(symbol);
  }
 public:

  // set up Resolver to resolve a Module
  static Resolver
  createForModuleStmt(Context* context, const uast::Module* mod,
                      const uast::AstNode* modStmt,
                      ResolutionResultByPostorderID& byPostorder);

  // set up Resolver to scope resolve a Module
  static Resolver
  createForScopeResolvingModuleStmt(
                      Context* context, const uast::Module* mod,
                      const uast::AstNode* modStmt,
                      ResolutionResultByPostorderID& byPostorder);

  // set up Resolver to resolve a potentially generic Function signature
  static Resolver
  createForInitialSignature(Context* context, const uast::Function* fn,
                            ResolutionResultByPostorderID& byPostorder);

  // set up Resolver to resolve an instantiation of a Function signature
  static Resolver
  createForInstantiatedSignature(Context* context,
                                 const uast::Function* fn,
                                 const SubstitutionsMap& substitutions,
                                 const PoiScope* poiScope,
                                 ResolutionResultByPostorderID& byPostorder);

  // set up Resolver to resolve a Function body/return type after
  // instantiation (if any instantiation was needed)
  static Resolver
  createForFunction(Context* context,
                   const uast::Function* fn,
                   const PoiScope* poiScope,
                   const TypedFnSignature* typedFnSignature,
                   ResolutionResultByPostorderID& byPostorder);

  static Resolver
  createForInitializer(Context* context,
                       const uast::Function* fn,
                       const PoiScope* poiScope,
                       const TypedFnSignature* typedFnSignature,
                       ResolutionResultByPostorderID& byPostorder);

  // set up Resolver to scope resolve a Function
  static Resolver
  createForScopeResolvingFunction(Context* context, const uast::Function* fn,
                                  ResolutionResultByPostorderID& byPostorder,
                                  owned <OuterVariables> outerVars);

  static Resolver createForScopeResolvingField(Context* context,
                                         const uast::AggregateDecl* ad,
                                         const uast::AstNode* fieldStmt,
                                         ResolutionResultByPostorderID& byPostorder);

  static Resolver createForScopeResolvingEnumConstant(Context* context,
                                         const uast::Enum* ed,
                                         const uast::AstNode* fieldStmt,
                                         ResolutionResultByPostorderID& byPostorder);

  // set up Resolver to initially resolve field declaration types
  static Resolver
  createForInitialFieldStmt(Context* context,
                            const uast::AggregateDecl* decl,
                            const uast::AstNode* fieldStmt,
                            const types::CompositeType* compositeType,
                            ResolutionResultByPostorderID& byPostorder,
                            DefaultsPolicy defaultsPolicy);

  // set up Resolver to resolve instantiated field declaration types
  static Resolver
  createForInstantiatedFieldStmt(Context* context,
                                 const uast::AggregateDecl* decl,
                                 const uast::AstNode* fieldStmt,
                                 const types::CompositeType* compositeType,
                                 const PoiScope* poiScope,
                                 ResolutionResultByPostorderID& byPostorder,
                                 DefaultsPolicy defaultsPolicy);

  // Set up Resolver to resolve the numeric values of enum elements
  static Resolver
  createForEnumElements(Context* context,
                        const uast::Enum* enumNode,
                        ResolutionResultByPostorderID& byPostorder);

  // set up Resolver to resolve instantiated field declaration types
  // without knowing the CompositeType
  static Resolver
  createForInstantiatedSignatureFields(Context* context,
                                       const uast::AggregateDecl* decl,
                                       const SubstitutionsMap& substitutions,
                                       const PoiScope* poiScope,
                                       ResolutionResultByPostorderID& byId);

  // set up Resolver to resolve a parent class type expression
  static Resolver
  createForParentClass(Context* context,
                       const uast::AggregateDecl* decl,
                       const SubstitutionsMap& substitutions,
                       const PoiScope* poiScope,
                       ResolutionResultByPostorderID& byPostorder);

  // set up Resolver to scope resolve a parent class type expression
  static Resolver
  createForParentClassScopeResolve(Context* context,
                                   const uast::AggregateDecl* decl,
                                   ResolutionResultByPostorderID& byPostorder);

  // set up Resolver to resolve a param for loop body
  static Resolver paramLoopResolver(Resolver& parent,
                                    const uast::For* loop,
                                    ResolutionResultByPostorderID& bodyResults);

  /**
    During AST traversal, find the last called expression we entered.
    e.g., will return 'f' if we just entered 'f()'.
   */
  const chpl::uast::AstNode* nearestCalledExpression() const;

  // Set the composite type of this Resolver. It is an error to call this
  // method when a composite type is already set.
  void setCompositeType(const types::CompositeType* ct);

  /* Get the formal types from a Resolver that computed them
   */
  std::vector<types::QualifiedType> getFormalTypes(const uast::Function* fn);

  /* Returns ErroneousType and emits the error message msg
     relevant to location for 'ast'.
   */
  types::QualifiedType typeErr(const uast::AstNode* ast, const char* msg);

  /* Determine the method receiver, which is a type under
     full resolution, but only an ID under scope resolution.
    */
  bool getMethodReceiver(types::QualifiedType* outType = nullptr,
                         ID* outId = nullptr);

  /* Compute the receiver type (when resolving a method)
     and return a type containing nullptr if it is not applicable.

     This one is different from getMethodReceiver in two ways:
       1. It isn't useful during scope resolution
       2. For declarations contained in a class or record (even if they are
          not methods), it will return the class/record type here.
   */
  types::QualifiedType methodReceiverType();

  /* Return a helper that can compute the additional scopes
     that need to be consulted for resolving symbols within a method. */
  const ReceiverScopeHelper* getMethodReceiverScopeHelper();

  /* Given an identifier, check if this identifier could refer to a superclass,
     as opposed to a variable of the name 'super'. If it can, sets
     outType to the type of the current method's receiver.
   */
  bool isPotentialSuper(const uast::Identifier* identifier,
                        types::QualifiedType* outType = nullptr);
  /* Given a type of a child / sub type, give type of the parent / super type.
   */
  types::QualifiedType getSuperType(Context* context,
                                    const types::QualifiedType& sub,
                                    const uast::Identifier* identForError);

  /* When resolving a generic record or a generic function,
     there might be generic types that we don't know yet.
     E.g.

       proc f(type t, arg: t)

     before instantiating, we should conclude that:
       * t has type AnyType
       * arg has type UnknownType (and in particular, not AnyType)

     But, if we have a substitution for `t`, we should use that.
   */
  bool shouldUseUnknownTypeForGeneric(const ID& id);

  // helper for resolveTypeQueriesFromFormalType
  void resolveTypeQueries(const uast::AstNode* formalTypeExpr,
                          const types::QualifiedType& actualType,
                          bool isNonStarVarArg = false,
                          bool isTopLevel = true);

  /* When resolving a function with a TypeQuery, we need to
     resolve the type that is queried, since it can be used
     on its own later.

     E.g.

       proc a(arg: ?t) { }
       proc b(arg: GenericRecord(?u)) { }

     This function resolves the types of all TypeQuery nodes
     contained in the passed Formal (by updating 'byPostorder').
   */
  void resolveTypeQueriesFromFormalType(const uast::VarLikeDecl* formal,
                                        types::QualifiedType formalType);

  // helper for getTypeForDecl -- checks the Kinds are compatible
  // if so, returns false.
  // if not, issues error(s) and returns true.
  bool checkForKindError(const uast::AstNode* typeForErr,
                         const uast::AstNode* initForErr,
                         types::QualifiedType::Kind declKind,
                         types::QualifiedType declaredType,
                         types::QualifiedType initExprType);

  const types::Type* computeCustomInferType(const uast::AstNode* initExpr,
                                            const types::CompositeType* ct);

  // Helper to figure out what type to use for a declaration
  // that can have both a declared type and an init expression.
  // If both are provided, checks that they are compatible.
  // Returns the type to use for the declaration.
  types::QualifiedType getTypeForDecl(const uast::AstNode* declForErr,
                                      const uast::AstNode* typeForErr,
                                      const uast::AstNode* initForErr,
                                      types::QualifiedType::Kind declKind,
                                      types::QualifiedType declaredType,
                                      types::QualifiedType initExprType);

  // helper to resolve a NamedDecl
  // useType will be used to set the type if it is not nullptr
  void resolveNamedDecl(const uast::NamedDecl* decl,
                        const types::Type* useType);

  // helper to compute the intent for formals
  // (including type constructor formals)
  void computeFormalIntent(const uast::NamedDecl* decl,
                                 types::QualifiedType::Kind& qtKind,
                           const types::Type* typePtr,
                           const types::Param* paramPtr);

  // issue ambiguity / no matching candidates / etc error
  void issueErrorForFailedCallResolution(const uast::AstNode* astForErr,
                                         const CallInfo& ci,
                                         const CallResolutionResult& c);

  // issue error for M.x where x is not found in a module M
  void issueErrorForFailedModuleDot(const uast::Dot* dot,
                                    ID moduleId,
                                    LookupConfig failedConfig);

  // after resolving the child nodes of the call as needed, perform call resolution
  // if appropriate. This is a helper function because it has some complicated
  // control flow, and we want to make sure to always keep callNodeStack in sync.
  void handleCallExpr(const uast::Call* call);

  // handle the result of one of the functions to resolve a call. Handles:
  //  * r.setMostSpecific
  //  * r.setPoiScope
  //  * r.setType
  //  * poiInfo.accumulate
  //
  // Does not handle:
  //
  //  * issueErrorForFailedCallResolution if there was an error
  //
  // Instead, returns 'true' if an error needs to be issued.
  bool handleResolvedCallWithoutError(ResolvedExpression& r,
                                      const uast::AstNode* astForErr,
                                      const CallInfo& ci,
                                      const CallResolutionResult& c,
                                      optional<ActionAndId> associatedActionAndId = {});
  // Same as handleResolvedCallWithoutError, except actually issues the error.
  void handleResolvedCall(ResolvedExpression& r,
                          const uast::AstNode* astForErr,
                          const CallInfo& ci,
                          const CallResolutionResult& c,
                          optional<ActionAndId> associatedActionAndId = {});
  // like handleResolvedCall, but prints the candidates that were rejected
  // by the error in detail.
  void handleResolvedCallPrintCandidates(ResolvedExpression& r,
                                         const uast::Call* call,
                                         const CallInfo& ci,
                                         const CallScopeInfo& inScopes,
                                         const types::QualifiedType& receiverType,
                                         const CallResolutionResult& c,
                                         optional<ActionAndId> associatedActionAndId = {});

  // If the variable with the passed ID has unknown or generic type,
  // and it has not yet been initialized, set its type to rhsType.
  // Also sets lhsExprAst to have this new type.
  void adjustTypesForSplitInit(ID id,
                               const types::QualifiedType& rhsType,
                               const uast::AstNode* lhsExprAst,
                               const uast::AstNode* astForErr);

  // handles setting types of variables for split init with '='
  void adjustTypesOnAssign(const uast::AstNode* lhsAst,
                           const uast::AstNode* rhsAst);

  // handles setting types of variables for split init with 'out' formals
  void adjustTypesForOutFormals(const CallInfo& ci,
                                const std::vector<const uast::AstNode*>& asts,
                                const MostSpecificCandidates& fns);

  // e.g. (a, b) = mytuple
  // checks that tuple size matches and that the elements are assignable
  // saves any '=' called into r.associatedFns
  void resolveTupleUnpackAssign(ResolvedExpression& r,
                                const uast::AstNode* astForErr,
                                const uast::Tuple* lhsTuple,
                                types::QualifiedType lhsType,
                                types::QualifiedType rhsType);

  // helper for resolveTupleDecl
  // e.g. var (a, b) = mytuple
  // checks that tuple size matches and establishes types for a and b
  void resolveTupleUnpackDecl(const uast::TupleDecl* lhsTuple,
                              types::QualifiedType rhsType);

  // e.g. var (a, b) = mytuple
  void resolveTupleDecl(const uast::TupleDecl* td,
                        const types::Type* useType);

  void validateAndSetToId(ResolvedExpression& r,
                          const uast::AstNode* exr,
                          const ID& id);

  void validateAndSetMostSpecific(ResolvedExpression& r,
                                  const uast::AstNode* exr,
                                  const MostSpecificCandidates& mostSpecific);

  // e.g. new shared C(a, 0)
  // also resolves initializer call as a side effect
  bool resolveSpecialNewCall(const uast::Call* call);

  // resolve a special op call such as tuple unpack assign
  bool resolveSpecialOpCall(const uast::Call* call);

  // resolve a special primitive call such as 'resolves', which has its
  // own logic for traversing actuals etc.
  bool resolveSpecialPrimitiveCall(const uast::Call* call);

  // resolve a keyword call like index(D)
  bool resolveSpecialKeywordCall(const uast::Call* call);

  // Resolve a || or && operation.
  types::QualifiedType typeForBooleanOp(const uast::OpCall* op);

  // find the element, if any, that a name refers to.
  // Sets outAmbiguous to true if multiple elements of the same name are found,
  // and to false otherwise.
  ID scopeResolveEnumElement(const uast::Enum* enumAst,
                             UniqueString elementName,
                             const uast::AstNode* nodeForErr,
                             bool& outAmbiguous);
  // Given the results of looking up an enum element, construct a QualifiedType.
  types::QualifiedType
  typeForScopeResolvedEnumElement(const types::EnumType* enumType,
                                  const ID& refersToId,
                                  bool ambiguous);
  types::QualifiedType
  typeForScopeResolvedEnumElement(const ID& enumTypeId,
                                  const ID& refersToId,
                                  bool ambiguous);
  // Given a particular enum type, determine the type of a particular element.
  types::QualifiedType typeForEnumElement(const types::EnumType* type,
                                          UniqueString elemName,
                                          const uast::AstNode* astForErr);

  // helper to resolve a special call
  // returns 'true' if the call was a special call handled here, false
  // if it is a regular call.
  bool resolveSpecialCall(const uast::Call* call);

  /* What is the type for the symbol with a particular ID?
     localGenericUnknown, if true, indicates that a use of a
     field/formal with generic type (that is not substituted)
     should be resolved to unknown. That is important
     for initial resolution of such functions/types.
   */
  types::QualifiedType typeForId(const ID& id, bool localGenericToUnknown);

  // prepare the CallInfoActuals by inspecting the actuals of a call
  // includes special handling for operators and tuple literals
  void prepareCallInfoActuals(const uast::Call* call,
                              std::vector<CallInfoActual>& actuals,
                              const uast::AstNode*& questionArg);

  // prepare a CallInfo by inspecting the called expression and actuals
  CallInfo prepareCallInfoNormalCall(const uast::Call* call);

  bool identHasMoreMentions(const uast::Identifier* ident);

  // When an identifier is ambiguous, try issuing an error, but only if
  // one hasn't been issued before. In doing so, re-run scope search to
  // figure out how each candidate was found.
  void issueAmbiguityErrorIfNeeded(const chpl::uast::Identifier* ident,
                                   const Scope* scope,
                                   LookupConfig prevConfig);

  MatchingIdsWithName
  lookupIdentifier(const uast::Identifier* ident,
                   ParenlessOverloadInfo& outParenlessOverloadInfo);


  void tryResolveParenlessCall(const ParenlessOverloadInfo& info,
                               const uast::Identifier* ident);

  void resolveIdentifier(const uast::Identifier* ident);

  /* Resolver keeps a stack of scopes and a stack of decls.
     enterScope and exitScope update those stacks. */
  void enterScope(const uast::AstNode* ast);
  void exitScope(const uast::AstNode* ast);

  /* Returns 'true' if the Resolver has recursed inside of a node of the
     given AstTag. */
  bool isInsideTag(uast::asttags::AstTag tag) const;

  // the visitor methods
  bool enter(const uast::Conditional* cond);
  void exit(const uast::Conditional* cond);

  bool enter(const uast::Select* sel);
  void exit(const uast::Select* sel);

  bool enter(const uast::Literal* literal);
  void exit(const uast::Literal* literal);

  bool enter(const uast::Identifier* ident);
  void exit(const uast::Identifier* ident);

  bool enter(const uast::Init* init);
  void exit(const uast::Init* init);

  bool enter(const uast::TypeQuery* tq);
  void exit(const uast::TypeQuery* tq);

  bool enter(const uast::NamedDecl* decl);
  void exit(const uast::NamedDecl* decl);

  bool enter(const uast::MultiDecl* decl);
  void exit(const uast::MultiDecl* decl);

  bool enter(const uast::TupleDecl* decl);
  void exit(const uast::TupleDecl* decl);

  bool enter(const uast::ForwardingDecl* decl);
  void exit(const uast::ForwardingDecl* decl);

  bool enter(const uast::Range* decl);
  void exit(const uast::Range* decl);

  bool enter(const uast::Domain* decl);
  void exit(const uast::Domain* decl);

  // Note: Call cases here include Tuple
  bool enter(const uast::Call* call);
  void exit(const uast::Call* call);

  bool enter(const uast::Dot* dot);
  void exit(const uast::Dot* dot);

  bool enter(const uast::New* node);
  void exit(const uast::New* node);

  bool enter(const uast::IndexableLoop* loop);
  void exit(const uast::IndexableLoop* loop);

  bool enter(const uast::DoWhile* loop);
  void exit(const uast::DoWhile* loop);

  bool enter(const uast::ReduceIntent* reduce);
  void exit(const uast::ReduceIntent* reduce);

  bool enter(const uast::Reduce* reduce);
  void exit(const uast::Reduce* reduce);

  bool enter(const uast::TaskVar* taskVar);
  void exit(const uast::TaskVar* taskVar);

  bool enter(const uast::Return* ret);
  void exit(const uast::Return* ret);

  bool enter(const uast::Throw* ret);
  void exit(const uast::Throw* ret);

  bool enter(const uast::Try* ret);
  void exit(const uast::Try* ret);

  bool enter(const uast::Catch* ret);
  void exit(const uast::Catch* ret);

  bool enter(const uast::Use* node);
  void exit(const uast::Use* node);

  bool enter(const uast::Import* node);
  void exit(const uast::Import* node);

  // if none of the above is called, fall back on this one
  bool enter(const uast::AstNode* ast);
  void exit(const uast::AstNode* ast);
};

} // end namespace resolution
} // end namespace chpl

#endif
