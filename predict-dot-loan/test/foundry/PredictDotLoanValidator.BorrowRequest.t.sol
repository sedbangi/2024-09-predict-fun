// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {IPredictDotLoan} from "../../contracts/interfaces/IPredictDotLoan.sol";
import {PredictDotLoanValidator} from "../../contracts/PredictDotLoanValidator.sol";
import {MockERC20} from "../mock/MockERC20.sol";
import {MockUmaCtfAdapter} from "../mock/MockUmaCtfAdapter.sol";
import {ConditionalTokens} from "../mock/ConditionalTokens/ConditionalTokens.sol";
import {MockCTFExchange} from "../mock/CTFExchange/MockCTFExchange.sol";
import {MockNegRiskAdapter} from "../mock/NegRiskAdapter/MockNegRiskAdapter.sol";
import {TestHelpers} from "./TestHelpers.sol";
import "../../contracts/ValidationCodeConstants.sol";

contract PredictDotLoanValidator_BorrowRequest_Test is TestHelpers {
    PredictDotLoanValidator internal predictDotLoanValidator;

    function setUp() public {
        _deploy();

        mockERC20.mint(lender, LOAN_AMOUNT);

        vm.prank(lender);
        mockERC20.approve(address(predictDotLoan), LOAN_AMOUNT);

        vm.prank(borrower);
        mockCTF.setApprovalForAll(address(predictDotLoan), true);

        _mintCTF(borrower);
        _mintNegRiskCTF(borrower);

        predictDotLoanValidator = new PredictDotLoanValidator(address(predictDotLoan));
    }

    function test_validateProposal_BorrowRequest() public view {
        IPredictDotLoan.Proposal memory proposal = _generateBorrowRequest(IPredictDotLoan.QuestionType.Binary);
        uint256[10] memory validationCodes = predictDotLoanValidator.validateProposal(
            proposal,
            lender,
            proposal.loanAmount
        );
        assertEq(validationCodes[0], PROPOSAL_EXPECTED_TO_BE_VALID);
        assertEq(validationCodes[1], PROPOSAL_EXPECTED_TO_BE_VALID);
        assertEq(validationCodes[2], PROPOSAL_EXPECTED_TO_BE_VALID);
        assertEq(validationCodes[3], PROPOSAL_EXPECTED_TO_BE_VALID);
        assertEq(validationCodes[4], PROPOSAL_EXPECTED_TO_BE_VALID);
        assertEq(validationCodes[5], PROPOSAL_EXPECTED_TO_BE_VALID);
        assertEq(validationCodes[6], PROPOSAL_EXPECTED_TO_BE_VALID);
        assertEq(validationCodes[7], PROPOSAL_EXPECTED_TO_BE_VALID);
        assertEq(validationCodes[8], PROPOSAL_EXPECTED_TO_BE_VALID);
        assertEq(validationCodes[9], PROPOSAL_EXPECTED_TO_BE_VALID);
    }

    function test_validateProposal_Expired_BorrowRequest() public {
        IPredictDotLoan.Proposal memory proposal = _generateBorrowRequest(IPredictDotLoan.QuestionType.Binary);

        vm.warp(vm.getBlockTimestamp() + proposal.validUntil + 1 seconds);

        uint256[10] memory validationCodes = predictDotLoanValidator.validateProposal(
            proposal,
            lender,
            proposal.loanAmount
        );
        assertEq(validationCodes[0], PROPOSAL_EXPIRED);
    }

    function test_validateProposal_LenderIsBorrower_BorrowRequest() public view {
        IPredictDotLoan.Proposal memory proposal = _generateBorrowRequest(IPredictDotLoan.QuestionType.Binary);
        uint256[10] memory validationCodes = predictDotLoanValidator.validateProposal(
            proposal,
            borrower,
            proposal.loanAmount
        );
        assertEq(validationCodes[1], LENDER_IS_BORROWER);
    }

    function test_validateProposal_InvalidSignature_BorrowRequest() public view {
        IPredictDotLoan.Proposal memory proposal = _generateBorrowRequest(IPredictDotLoan.QuestionType.Binary);
        proposal.from = address(69);
        proposal.signature = _signProposal(proposal);
        uint256[10] memory validationCodes = predictDotLoanValidator.validateProposal(
            proposal,
            borrower,
            proposal.loanAmount
        );
        assertEq(validationCodes[2], INVALID_SIGNATURE);
    }

    function testFuzz_validateProposal_FulfillAmountTooLow_BorrowRequest(uint256 amount) public view {
        vm.assume(amount < LOAN_AMOUNT / 10);

        IPredictDotLoan.Proposal memory proposal = _generateBorrowRequest(IPredictDotLoan.QuestionType.Binary);

        uint256[10] memory validationCodes = predictDotLoanValidator.validateProposal(proposal, borrower, amount);
        assertEq(validationCodes[3], FULFILL_AMOUNT_TOO_LOW);
    }

    function testFuzz_validateProposal_FulfillAmountTooHigh_BorrowRequest(uint256 amount) public view {
        vm.assume(amount > LOAN_AMOUNT);

        IPredictDotLoan.Proposal memory proposal = _generateBorrowRequest(IPredictDotLoan.QuestionType.Binary);

        uint256[10] memory validationCodes = predictDotLoanValidator.validateProposal(proposal, borrower, amount);
        assertEq(validationCodes[3], FULFILL_AMOUNT_TOO_HIGH);
    }

    function test_validateProposal_Cancelled_BorrowRequest() public {
        IPredictDotLoan.Proposal memory proposal = _generateBorrowRequest(IPredictDotLoan.QuestionType.Binary);

        _cancelBorrowingSalt(proposal.salt);

        uint256[10] memory validationCodes = predictDotLoanValidator.validateProposal(
            proposal,
            borrower,
            proposal.loanAmount
        );
        assertEq(validationCodes[4], PROPOSAL_CANCELLED);
    }

    function test_validateProposal_SaltAlreadyUsed_BorrowRequest() public {
        IPredictDotLoan.Proposal memory proposal = _generateBorrowRequest(IPredictDotLoan.QuestionType.Binary);

        vm.prank(lender);
        predictDotLoan.acceptBorrowRequest(proposal, proposal.loanAmount);

        IPredictDotLoan.Proposal memory proposalTwo = _generateBorrowRequest(IPredictDotLoan.QuestionType.Binary);
        proposalTwo.loanAmount = LOAN_AMOUNT + 1;
        proposalTwo.salt = proposal.salt;
        proposalTwo.signature = _signProposal(proposalTwo);

        uint256[10] memory validationCodes = predictDotLoanValidator.validateProposal(
            proposalTwo,
            lender,
            proposalTwo.loanAmount
        );
        assertEq(validationCodes[4], SALT_ALREADY_USED);
    }

    function test_validateProposal_BorrowingNonceIsNotCurrent() public {
        IPredictDotLoan.Proposal memory proposal = _generateBorrowRequest(IPredictDotLoan.QuestionType.Binary);

        vm.prank(borrower);
        predictDotLoan.incrementNonces(false, true);

        uint256[10] memory validationCodes = predictDotLoanValidator.validateProposal(
            proposal,
            borrower,
            proposal.loanAmount
        );
        assertEq(validationCodes[5], NONCE_IS_NOT_CURRENT);
    }

    function testFuzz_validateProposal_CollateralizationRatioTooLow_BorrowRequest(
        uint256 collateralAmount
    ) public view {
        vm.assume(collateralAmount < LOAN_AMOUNT);

        IPredictDotLoan.Proposal memory proposal = _generateBorrowRequest(IPredictDotLoan.QuestionType.Binary);
        proposal.collateralAmount = collateralAmount;
        proposal.signature = _signProposal(proposal, borrowerPrivateKey);

        uint256[10] memory validationCodes = predictDotLoanValidator.validateProposal(
            proposal,
            lender,
            proposal.loanAmount
        );
        assertEq(validationCodes[6], COLLATERALIZATION_RATIO_BELOW_100);
    }

    function testFuzz_validateProposal_InterestRateTooLow_BorrowRequest(uint256 interestRatePerSecond) public view {
        vm.assume(interestRatePerSecond <= ONE);

        IPredictDotLoan.Proposal memory proposal = _generateBorrowRequest(IPredictDotLoan.QuestionType.Binary);
        proposal.interestRatePerSecond = interestRatePerSecond;
        proposal.signature = _signProposal(proposal);

        uint256[10] memory validationCodes = predictDotLoanValidator.validateProposal(
            proposal,
            lender,
            proposal.loanAmount
        );
        assertEq(validationCodes[7], INTEREST_RATE_TOO_LOW);
    }

    function testFuzz_validateProposal_InterestRateTooHigh_BorrowRequest(uint256 interestRatePerSecond) public view {
        vm.assume(interestRatePerSecond > ONE + TEN_THOUSAND_APY);

        IPredictDotLoan.Proposal memory proposal = _generateBorrowRequest(IPredictDotLoan.QuestionType.Binary);
        proposal.interestRatePerSecond = interestRatePerSecond;
        proposal.signature = _signProposal(proposal);

        uint256[10] memory validationCodes = predictDotLoanValidator.validateProposal(
            proposal,
            lender,
            proposal.loanAmount
        );
        assertEq(validationCodes[7], INTEREST_RATE_TOO_HIGH);
    }

    function test_validateProposal_PositionIsNotTradeable_BorrowRequest() public {
        mockCTFExchange.deregisterToken(_getPositionId(true), _getPositionId(false));
        IPredictDotLoan.Proposal memory proposal = _generateBorrowRequest(IPredictDotLoan.QuestionType.Binary);

        uint256[10] memory validationCodes = predictDotLoanValidator.validateProposal(
            proposal,
            lender,
            proposal.loanAmount
        );
        assertEq(validationCodes[8], POSITION_IS_NOT_TRADEABLE);
    }

    function test_validateProposal_QuestionResolved_BorrowRequest() public {
        IPredictDotLoan.Proposal memory proposal = _generateBorrowRequest(IPredictDotLoan.QuestionType.Binary);

        mockUmaCtfAdapter.setPayoutStatus(questionId, MockUmaCtfAdapter.PayoutStatus.HasPrice);

        uint256[10] memory validationCodes = predictDotLoanValidator.validateProposal(
            proposal,
            lender,
            proposal.loanAmount
        );
        assertEq(validationCodes[9], QUESTION_RESOLVED);
    }

    function test_validateProposal_MarketResolved_BorrowRequest() public {
        IPredictDotLoan.Proposal memory proposal = _generateBorrowRequest(IPredictDotLoan.QuestionType.NegRisk);

        mockNegRiskAdapter.setDetermined(negRiskQuestionId, true);

        uint256[10] memory validationCodes = predictDotLoanValidator.validateProposal(
            proposal,
            lender,
            proposal.loanAmount
        );
        assertEq(validationCodes[9], MARKET_RESOLVED);
    }

    function test_validateProposal_QuestionStateAbnormal_BorrowRequest() public {
        IPredictDotLoan.Proposal memory proposal = _generateBorrowRequest(IPredictDotLoan.QuestionType.Binary);

        mockUmaCtfAdapter.setPayoutStatus(questionId, MockUmaCtfAdapter.PayoutStatus.Flagged);

        uint256[10] memory validationCodes = predictDotLoanValidator.validateProposal(
            proposal,
            lender,
            proposal.loanAmount
        );
        assertEq(validationCodes[9], QUESTION_STATE_ABNORMAL);

        mockUmaCtfAdapter.setPayoutStatus(questionId, MockUmaCtfAdapter.PayoutStatus.NotInitialized);

        validationCodes = predictDotLoanValidator.validateProposal(proposal, lender, proposal.loanAmount);
        assertEq(validationCodes[9], QUESTION_STATE_ABNORMAL);

        mockUmaCtfAdapter.setPayoutStatus(questionId, MockUmaCtfAdapter.PayoutStatus.Paused);

        validationCodes = predictDotLoanValidator.validateProposal(proposal, lender, proposal.loanAmount);
        assertEq(validationCodes[9], QUESTION_STATE_ABNORMAL);
    }
}
