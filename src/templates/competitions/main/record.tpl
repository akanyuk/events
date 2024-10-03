<?php
/**
 * @var int $competitionID
 * @var bool $hideWorksCount
 * @var array $competitions
 * @var array $competitionsGroups
 * @var string $votingBlock
 * @var string $worksBlock
 * @var string $announcement
 * @var string $workComments
 */

NFW::i()->registerFunction('competitions_list_short');
$compoList = competitions_list_short($competitionsGroups, $competitions, $hideWorksCount, true, $competitionID);

// Right column content
ob_start();
?>
<div class="d-none d-md-block">
    <div class="mb-5"><?php echo $announcement ?></div>
</div>
<?php
echo $compoList;
NFWX::i()->mainLayoutRightContent = ob_get_clean();

// Main content
?>
<div class="d-block d-md-none">
    <div class="mb-5"><?php echo $announcement ?></div>
</div>

<?php echo $votingBlock.$worksBlock.$workComments ?>

