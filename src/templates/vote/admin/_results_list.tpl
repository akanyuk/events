<?php
/**
 * @var vote $Module
 * @var array $records
 * @var string $calcBy
 */
foreach ($records as $competition) {
    echo '<tr><td></td><td></td><td><h4>' . htmlspecialchars($competition['title']) . '</h4></td></tr>';
    foreach ($competition['works'] as $record) {
        switch ($calcBy) {
            case "iqm":
                $score = number_format($record['iqm_vote'], 2);
                break;
            case "sum":
                $score = $record['total_scores'];
                break;
            default:
                $score = number_format($record['average_vote'], 2);
        }
        ?>
        <tr>
            <td class="nowrap"><code><b><?php echo $score ?></b></code> <small class="text-muted" title="Total votes"><?php echo $record['num_votes'] ?></small></td>
            <td><div class="label label-default"><?php echo $record['place'] ?></div></td>
            <td><?php echo htmlspecialchars($record['title'] . ' by ' . $record['author']) ?></td>
        </tr>
        <?php
    }
}

